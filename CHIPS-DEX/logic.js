/*global getCurrentParticipant getParticipantRegistry getFactory emit */
/**
 * A Department grants access to its beneficiary details to another department.
 *@param {org.chips.dex.AuthorizeAccess} authorize - Authorized access to beneficiary details processed
 *@transaction
 */
async function authorizeAccess(authorize) {
  
  const ben =authorize.benId;
  
  console.log('****AUTH:' + ben.owner.depName + 'granting access to '+ authorize.depId);
  
  if(!ben){
    throw new Error('Beneficiary details does not exist.')
  }
  
  let index = -1;
  
  if(!ben.authorized) {
     ben.authorized=[];
     }
     else {
     	index = ben.authorized.indexOf(authorize.depId.depId);
	}
	if(index < 0) {
  	ben.authorized.push(authorize.depId.depId);
  
  	const event = getFactory().newEvent('org.chips.dex','DepartmentEvent');
  
  	event.departmentTransaction = authorize;
  
  	emit(event);
    
  	const BeneficiaryRegistry= await getAssetRegistry('org.chips.dex.Beneficiary')
  	await BeneficiaryRegistry.update(ben);
}
}

/**
 * A Department revokes access to their record from another Department.
 * @param {org.chips.dex.RevokeAccess} revoke - the RevokeAccess to be processed
 * @transaction
 */
async function revokeAccess(revoke) {  // eslint-disable-line no-unused-vars

    const ben =revoke.benId;
    console.log('**** REVOKE: ' + ben.owner.depName + ' revoking access to ' + revoke.depId );

    if(!ben) {
        throw new Error('Beneficiary details does not exist.');
    }

    // if the member is authorized, we remove them
    const index = ben.authorized ? ben.authorized.indexOf(revoke.depId.depId) : -1;

    if(index>-1) {
        me.authorized.splice(index, 1);

        // emit an event
        const event = getFactory().newEvent('org.chips.dex', 'DepartmentEvent');
        event.departmentTransaction = revoke;
        emit(event);

        // persist the state of the member
        const BeneficiaryRegistry = await getAssetRegistry('org.chips.dex.Beneficiary');
        await BeneficiaryRegistry.update(ben);
    }
}
  
  
  

