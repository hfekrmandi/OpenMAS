%%%%%%%%%%%%%%%%%%%%%%%%% UPDATE PROCEDURES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATE THE GLOBAL STATE VECTORS FROM ENTITY.VIRTUAL
function [METAObjUpdate]	= OMAS_updateGlobalStates(SIM,objectID,globalVelocity_k,quaternion_k,globalState_k,idleStatus_k)
% This function reallocates the global properties of each entity to the 
% META.OBJECT series to allow faster reference and increased independance
% of the main cycle from the object cycles.

% CONFIRM OBJECT VARIABLES
assert(isa(objectID,'uint16')   == 1,'The objectID must be a uint16 type');
assert(islogical(idleStatus_k)  == 1,'The idle agent status must be reported as a logical');
assert(size(globalVelocity_k,1) == 3 && isnumeric(globalVelocity_k),'Object velocity update must be given as a column vector [3x1].');
assert(size(quaternion_k,1)     == 4 && isnumeric(quaternion_k),'Object quaternion update must be given as a column vector [4x1].');
assert(any(isnan(quaternion_k)) == 0,sprintf('Quaternion for objectID %d is invalid; q = [%f %f %f %f]',int8(objectID),quaternion_k(1),quaternion_k(2),quaternion_k(3),quaternion_k(4)));

% IDENTIFY THE ASSOCIATED META OBJECT 
logicalIndices = SIM.globalIDvector == objectID;                           % The logical position of the ID
index = inf;
for i = 1:numel(logicalIndices)
   if logicalIndices(i)
      index = i; 
      break
   end
end

% EXTRACT THE META STRUCTURE TO BE UPDATED 
METAObjUpdate = SIM.OBJECTS(1,index);                                      % Get the current META object associated with 'entity'

% //////////////////////// UPDATE META.OBJECT /////////////////////////////
% UPDATE THE META ROTATION DEFINING FIXED LOCAL >> ROTATED IN THE GLOBAL
METAObjUpdate.R = OMAS_geometry.quaternionToRotationMatrix(quaternion_k);
% UPDATE THE GLOBAL POSITION
globalPosition_k = METAObjUpdate.globalState(1:3) + globalVelocity_k*SIM.TIME.dt; % Calculate the new global position

percentage = 0.05;
noise_std = 0.0001 * eye(12);
noise_std(1:3,1:3) = diag((SIM.TIME.dt * globalVelocity_k * percentage).^2);
noise_std(4:6,4:6) = diag((SIM.TIME.dt * globalState_k(10:12) * percentage).^2);
noise = mvnrnd(zeros(1, 12), noise_std)';

globalPosition_k = globalPosition_k + noise(1:3);
quaternion_k = eul2quat(quat2eul(quaternion_k') + noise(4:6)')';
globalVelocity_k = globalVelocity_k + noise(1:3);
globalState_k = globalState_k + noise;

% Update information/consensus state
% pos = globalPosition_k;
% vel = globalVelocity_k;
% eul = quat2eul(quaternion_k');
% eul_vel = 7;
% METAObjUpdate.X = quat2eul(quaternion_k');
METAObjUpdate.eulZYX = quat2eul(quaternion_k');
METAObjUpdate.X = [globalPosition_k;globalVelocity_k;quat2eul(quaternion_k')';globalState_k(10:12)];

% REBUILD GLOBAL STATES (ENTITY & META)
METAObjUpdate.globalState = [globalPosition_k;globalVelocity_k;quaternion_k]; 
% DETERMINE IF ENTITY HAS INDICATED THAT TASK IS COMPLETE
METAObjUpdate.idleStatus = idleStatus_k;
end