pragma solidity ^ 0.4 .0;
library SafeMath {
    function mul(uint a, uint b) internal returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal returns(uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal returns(uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal constant returns(uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns(uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns(uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns(uint256) {
        return a < b ? a : b;
    }

    function assert(bool assertion) internal {
        if (!assertion) {
            throw;
        }
    }
}

library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart: = and(mload(src), not(mask))
            let destpart: = and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string self) internal returns(slice) {
        uint ptr;
        assembly {
            ptr: = add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    /*
     * @dev Returns the length of a null-terminated bytes32 string.
     * @param self The value to find the length of.
     * @return The length of the string, from 0 to 32.
     */
    function len(bytes32 self) internal returns(uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (self & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (self & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (self & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (self & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (self & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

    /*
     * @dev Returns a slice containing the entire bytes32, interpreted as a
     *      null-termintaed utf-8 string.
     * @param self The bytes32 value to convert to a slice.
     * @return A new slice containing the value of the input argument up to the
     *         first null.
     */
    function toSliceB32(bytes32 self) internal returns(slice ret) {
        // Allocate space for `self` in memory, copy it there, and point ret at it
        assembly {
            let ptr: = mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

    /*
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
    function copy(slice self) internal returns(slice) {
        return slice(self._len, self._ptr);
    }

    /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
    function toString(slice self) internal returns(string) {
        var ret = new string(self._len);
        uint retptr;
        assembly {
            retptr: = add(ret, 32)
        }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    /*
     * @dev Returns the length in runes of the slice. Note that this operation
     *      takes time proportional to the length of the slice; avoid using it
     *      in loops, and call `slice.empty()` if you only need to know whether
     *      the slice is empty or not.
     * @param self The slice to operate on.
     * @return The length of the slice in runes.
     */
    function len(slice self) internal returns(uint l) {
        // Starting at ptr-31 means the LSB will be the byte we care about
        var ptr = self._ptr - 31;
        var end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly {
                b: = and(mload(ptr), 0xFF)
            }
            if (b < 0x80) {
                ptr += 1;
            } else if (b < 0xE0) {
                ptr += 2;
            } else if (b < 0xF0) {
                ptr += 3;
            } else if (b < 0xF8) {
                ptr += 4;
            } else if (b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    /*
     * @dev Returns true if the slice is empty (has a length of 0).
     * @param self The slice to operate on.
     * @return True if the slice is empty, False otherwise.
     */
    function empty(slice self) internal returns(bool) {
        return self._len == 0;
    }

    /*
     * @dev Returns a positive number if `other` comes lexicographically after
     *      `self`, a negative number if it comes before, or zero if the
     *      contents of the two slices are equal. Comparison is done per-rune,
     *      on unicode codepoints.
     * @param self The first slice to compare.
     * @param other The second slice to compare.
     * @return The result of the comparison.
     */
    function compare(slice self, slice other) internal returns(int) {
        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        var selfptr = self._ptr;
        var otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a: = mload(selfptr)
                b: = mload(otherptr)
            }
            if (a != b) {
                // Mask out irrelevant bytes and check again
                uint mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                var diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    /*
     * @dev Returns true if the two slices contain the same text.
     * @param self The first slice to compare.
     * @param self The second slice to compare.
     * @return True if the slices are equal, false otherwise.
     */
    function equals(slice self, slice other) internal returns(bool) {
        return compare(self, other) == 0;
    }

    /*
     * @dev Extracts the first rune in the slice into `rune`, advancing the
     *      slice to point to the next rune and returning `self`.
     * @param self The slice to operate on.
     * @param rune The slice that will contain the first rune.
     * @return `rune`.
     */
    function nextRune(slice self, slice rune) internal returns(slice) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint len;
        uint b;
        // Load the first byte of the rune into the LSBs of b
        assembly {
            b: = and(mload(sub(mload(add(self, 32)), 31)), 0xFF)
        }
        if (b < 0x80) {
            len = 1;
        } else if (b < 0xE0) {
            len = 2;
        } else if (b < 0xF0) {
            len = 3;
        } else {
            len = 4;
        }

        // Check for truncated codepoints
        if (len > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += len;
        self._len -= len;
        rune._len = len;
        return rune;
    }

    /*
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
    function nextRune(slice self) internal returns(slice ret) {
        nextRune(self, ret);
    }

    /*
     * @dev Returns the number of the first codepoint in the slice.
     * @param self The slice to operate on.
     * @return The number of the first codepoint in the slice.
     */
    function ord(slice self) internal returns(uint ret) {
        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint length;
        uint divisor = 2 ** 248;

        // Load the rune into the MSBs of b
        assembly {
            word: = mload(mload(add(self, 32)))
        }
        var b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if (b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if (b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }

        // Check for truncated codepoints
        if (length > self._len) {
            return 0;
        }

        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                // Invalid UTF-8 sequence
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    /*
     * @dev Returns the keccak-256 hash of the slice.
     * @param self The slice to hash.
     * @return The hash of the slice.
     */
    function keccak(slice self) internal returns(bytes32 ret) {
        assembly {
            ret: = keccak256(mload(add(self, 32)), mload(self))
        }
    }

    /*
     * @dev Returns true if `self` starts with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function startsWith(slice self, slice needle) internal returns(bool) {
        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length: = mload(needle)
            let selfptr: = mload(add(self, 0x20))
            let needleptr: = mload(add(needle, 0x20))
            equal: = eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }

    /*
     * @dev If `self` starts with `needle`, `needle` is removed from the
     *      beginning of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function beyond(slice self, slice needle) internal returns(slice) {
        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length: = mload(needle)
                let selfptr: = mload(add(self, 0x20))
                let needleptr: = mload(add(needle, 0x20))
                equal: = eq(sha3(selfptr, length), sha3(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    /*
     * @dev Returns true if the slice ends with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function endsWith(slice self, slice needle) internal returns(bool) {
        if (self._len < needle._len) {
            return false;
        }

        var selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length: = mload(needle)
            let needleptr: = mload(add(needle, 0x20))
            equal: = eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }

    /*
     * @dev If `self` ends with `needle`, `needle` is removed from the
     *      end of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function until(slice self, slice needle) internal returns(slice) {
        if (self._len < needle._len) {
            return self;
        }

        var selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length: = mload(needle)
                let needleptr: = mload(add(needle, 0x20))
                equal: = eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    // Returns the memory address of the first byte of the first occurrence of
    // `needle` in `self`, or the first byte after `self` if not found.
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns(uint) {
        uint ptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                // Optimized assembly for 68 gas per byte on short strings
                assembly {
                    let mask: = not(sub(exp(2, mul(8, sub(32, needlelen))), 1))
                    let needledata: = and(mload(needleptr), mask)
                    let end: = add(selfptr, sub(selflen, needlelen))
                    ptr: = selfptr
                    loop:
                        jumpi(exit, eq(and(mload(ptr), mask), needledata))
                    ptr: = add(ptr, 1)
                    jumpi(loop, lt(sub(ptr, 1), end))
                    ptr: = add(selfptr, selflen)
                    exit:
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly {
                    hash: = sha3(needleptr, needlelen)
                }
                ptr = selfptr;
                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly {
                        testHash: = sha3(ptr, needlelen)
                    }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    // Returns the memory address of the first byte after the last occurrence of
    // `needle` in `self`, or the address of `self` if not found.
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns(uint) {
        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                // Optimized assembly for 69 gas per byte on short strings
                assembly {
                    let mask: = not(sub(exp(2, mul(8, sub(32, needlelen))), 1))
                    let needledata: = and(mload(needleptr), mask)
                    ptr: = add(selfptr, sub(selflen, needlelen))
                    loop:
                        jumpi(ret, eq(and(mload(ptr), mask), needledata))
                    ptr: = sub(ptr, 1)
                    jumpi(loop, gt(add(ptr, 1), selfptr))
                    ptr: = selfptr
                    jump(exit)
                    ret:
                        ptr: = add(ptr, needlelen)
                    exit:
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly {
                    hash: = sha3(needleptr, needlelen)
                }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly {
                        testHash: = sha3(ptr, needlelen)
                    }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    /*
     * @dev Modifies `self` to contain everything from the first occurrence of
     *      `needle` to the end of the slice. `self` is set to the empty slice
     *      if `needle` is not found.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function find(slice self, slice needle) internal returns(slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    /*
     * @dev Modifies `self` to contain the part of the string from the start of
     *      `self` to the end of the first occurrence of `needle`. If `needle`
     *      is not found, `self` is set to the empty slice.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function rfind(slice self, slice needle) internal returns(slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function split(slice self, slice needle, slice token) internal returns(slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
    function split(slice self, slice needle) internal returns(slice token) {
        split(self, needle, token);
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and `token` to everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function rsplit(slice self, slice needle, slice token) internal returns(slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and returning everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` after the last occurrence of `delim`.
     */
    function rsplit(slice self, slice needle) internal returns(slice token) {
        rsplit(self, needle, token);
    }

    /*
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return The number of occurrences of `needle` found in `self`.
     */
    function count(slice self, slice needle) internal returns(uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    /*
     * @dev Returns True if `self` contains `needle`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return True if `needle` is found in `self`, false otherwise.
     */
    function contains(slice self, slice needle) internal returns(bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
    function concat(slice self, slice other) internal returns(string) {
        var ret = new string(self._len + other._len);
        uint retptr;
        assembly {
            retptr: = add(ret, 32)
        }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    /*
     * @dev Joins an array of slices, using `self` as a delimiter, returning a
     *      newly allocated string.
     * @param self The delimiter to use.
     * @param parts A list of slices to join.
     * @return A newly allocated string containing all the slices in `parts`,
     *         joined with `self`.
     */
    function join(slice self, slice[] parts) internal returns(string) {
        if (parts.length == 0)
            return "";

        uint length = self._len * (parts.length - 1);
        for (uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        var ret = new string(length);
        uint retptr;
        assembly {
            retptr: = add(ret, 32)
        }

        for (i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}

contract Blockright {
    
    using SafeMath for uint;
    using strings for *;
    
    address admin;
    string email;
    string documentHash;
    string paymentTransactionId;
    uint totalCopyrightsCount = 0;
    uint totalCreditsIssuedWithoutCoupons = 0;
    uint totalCreditsIssuedFromCoupons = 0;

    struct user {
        string name;
        string password;
        string loginType;
        string id;
        uint credits;
        uint userCopyrightsCount;
        string socialData;
    }

    struct document {
        string email;
        string metadata;
        uint uploadCreditCharge;
    }

    struct payment {
        string planType;
        string amount;
        string paymentStatus;
        string email;
        string couponCode;
        uint creditsEarned;
    }

    mapping(string => user) users;
    mapping(string => bool) isUserRegistered;
    mapping(string => document) documents;
    mapping(string => bool) isDocumentUploaded;
    mapping(string => uint) coupons;
    mapping(string => bool) isCouponIssued;
    mapping(string => bool) isCouponRedeemed;
    mapping(string => payment) payments;
    mapping(string => bool) isPaymentSuccessful;

    event couponEvent(string _actionPerformed, string _code, uint _value, uint256 _time);
    event copyrightEvent(string _actionPerformed, string _documentHash, string _email, uint _uploadCreditCharge, string _metadata, uint256 _time);
    event userEvent(string _actionPerformed, string _email, string _name, uint256 _time);
    event transferEvent(string _actionPerformed, string _email, uint _creditsTransferred, uint256 _time);
    event paymentEvent(string _actionPerformed, string _paymentTransactionId, string _amount, string _email, uint256 _time);



    function Blockright() payable{
        admin = msg.sender;
    }

    function registerUser(string _email,
        string _name,
        string _password,
        string _loginType,
        string _id) {
        require(!isUserRegistered[_email]); 
            users[_email].name = _name;
            users[_email].password = _password;
            users[_email].loginType = _loginType;
            users[_email].id = _id;
            users[_email].credits = 100;
            users[_email].userCopyrightsCount = 0;
            isUserRegistered[_email] = true;
            totalCreditsIssuedWithoutCoupons = totalCreditsIssuedWithoutCoupons.add(100);
            userEvent("USER REGISTERED", _email, _name, now);
        
    }

    function updateUser(string _email,
        string _name,
        string _password,
        string _loginType,
        string _id) {
        require (isUserRegistered[_email] == true);
            users[_email].name = _name;
            users[_email].password = _password;
            users[_email].loginType = _loginType;
            users[_email].id = _id;
            userEvent("USER UPDATED", _email, _name, now);
        
    }

    function login(string _email, string _password, string _loginType) returns(bool) {
        if (isUserRegistered[_email] == true && stringsEqual(users[_email].password, _password) && stringsEqual(users[_email].loginType, _loginType)) {
            return true;
        } else
            return false;
    }

    function getProfile(string _email) returns(string, string, string, uint, uint, string) {
        return (users[_email].name,
            users[_email].loginType,
            users[_email].id,
            users[_email].credits,
            users[_email].userCopyrightsCount,
            users[_email].socialData);
    }

    function updateUserSocialData(string _email, string _socialData) {
        require(isUserRegistered[_email] == true); 
            users[_email].socialData = _socialData;
        
    }

    function uploadNewDocument(string _documentHash,
        string _email,
        string _metadata,
        uint _uploadCreditCharge) {
        require(isUserRegistered[_email]);
        documents[_documentHash].email = _email;
        documents[_documentHash].metadata = _metadata;
        documents[_documentHash].uploadCreditCharge = _uploadCreditCharge;
        isDocumentUploaded[_documentHash] = true;
        users[_email].userCopyrightsCount = users[_email].userCopyrightsCount.add(1);
        users[_email].credits = users[_email].credits.sub(_uploadCreditCharge);
        totalCopyrightsCount = totalCopyrightsCount.add(1);
        copyrightEvent("DOCUMENT UPLOADED", _documentHash, _email, _uploadCreditCharge, _metadata, now);
    }


    function getDocument(string _documentHash) returns(string, string, uint) {
        return (documents[_documentHash].email,
        documents[_documentHash].metadata, 
        documents[_documentHash].uploadCreditCharge );
    }

    function registerPayment(string _paymentTransactionId,
        string _planType,
        string _amount,
        string _paymentStatus,
        string _email,
        string _couponCode,
        uint _creditsEarned) {
        payments[_paymentTransactionId].planType = _planType;
        payments[_paymentTransactionId].amount = _amount;
        payments[_paymentTransactionId].paymentStatus = _paymentStatus;
        payments[_paymentTransactionId].email = _email;
        payments[_paymentTransactionId].couponCode = _couponCode;
        payments[_paymentTransactionId].creditsEarned = _creditsEarned;
        isPaymentSuccessful[_paymentTransactionId] = true;
        paymentEvent("PAYMENT REGISTERED", _paymentTransactionId, _amount, _email, now);
    }

    function transferCredits(string _email, uint _creditsToBeTransferred) {
        users[_email].credits = users[_email].credits.add(_creditsToBeTransferred);
        totalCreditsIssuedWithoutCoupons = totalCreditsIssuedWithoutCoupons.add(_creditsToBeTransferred);
        transferEvent("CREDITS TRANSFERRED", _email, _creditsToBeTransferred, now);
    }

    function issueCoupon(string _code, uint _value) {
        coupons[_code] = _value;
        isCouponIssued[_code] = true;
        couponEvent("COUPON ISSUED", _code, _value, now);
    }

    function updateCouponValue(string _code, uint _value) {
        if (isCouponIssued[_code] == true) {
            coupons[_code] = _value;
            couponEvent("COUPON UPDATED", _code, _value, now);
        }
    }

    function redeemCoupon(string _code, string _email) {
        if (isCouponIssued[_code] == true && isUserRegistered[_email] == true && isCouponRedeemed[_code] == false) {
            users[_email].credits = users[_email].credits.add(coupons[_code]);
            totalCreditsIssuedFromCoupons = totalCreditsIssuedFromCoupons.add(coupons[_code]);
            isCouponRedeemed[_code] = true;
            couponEvent("COUPON REDEEMED", _code, coupons[_code], now);
        }
    }

    function getUserCredits(string _email) returns(uint) {
        return users[_email].credits;
    }

    function getUserCopyrightsCount(string _email) returns(uint) {
        return users[_email].userCopyrightsCount;
    }

    function allCopyrightsCount() returns(uint) {
        return totalCopyrightsCount;
    }

    function getTotalCreditsIssued() returns(uint) {
        return totalCreditsIssuedFromCoupons.add(totalCreditsIssuedWithoutCoupons);
    }

    function getTotalCreditsIssuedFromCoupons() returns(uint) {
        return totalCreditsIssuedFromCoupons;
    }

    function getTotalCreditsIssuedWithoutCoupons() returns(uint) {
        return totalCreditsIssuedWithoutCoupons;
    }


    function isDocumentPresent(string _documentHash) returns(bool) {
        return isDocumentUploaded[_documentHash];
    }

    function stringsEqual(string storage _a, string memory _b) internal returns(bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i++)
            if (a[i] != b[i])
                return false;
        return true;
    }

}








