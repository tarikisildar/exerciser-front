enum UserRole{
  Patient,Doctor,Admin
}

const userRoleMap = {
  'Patient' : UserRole.Patient,
  'Doctor' : UserRole.Doctor,
  'Admin' : UserRole.Admin
};

const userRoleParser = {
  UserRole.Patient: 'Patient' ,
  UserRole.Doctor: 'Doctor' ,
  UserRole.Admin: 'Admin'
};