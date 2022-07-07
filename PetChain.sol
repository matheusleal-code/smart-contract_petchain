pragma solidity >=0.7.0 <0.9.0;

contract PetChain {

    uint public numberOfPets;
    uint public numberOfUsers;
    uint public numberOfVaccines;
    uint public numberOfVaccinations;

    // Tipos de usuários -> Provedor da vacina, Veterinário, Tutor, Verificador
    enum UserType { PROVIDER, VET, TUTOR, VERIFIER }

    // Estrutura - Pet
    struct PetStruct {
        uint petId;
        address petOwner;
        string petName;
    }

    // Estrutura - Tutor
    struct UserStruct {
        uint userId;
        address userAddress;
        string userName;
        UserType userType;
    }

    // Tipos de usuários -> Provedor da vacina, Veterinário, Tutor, Verificador
    enum VaccineStatus { AVAILABLE, UNAVAILABLE }

    // Estrutura - Vacina
    struct VaccineStruct {
        uint vaccineId;
        string brand;
        address provider;
        VaccineStatus status;
    }

    // Estrutura - Vacinação
    struct VaccinationStruct {
        uint vaccinationId;
        address providerVaccine;
        address petOwner;
        address vetVaccined;
        uint vaccineId;
        uint petId;
    }

    mapping (address => uint[]) public myPets;
    PetStruct[] private pets;

    mapping (address => UserStruct) public userAccounts;
    UserStruct[] private users;

    mapping (address => uint[]) public myVaccines;
    mapping (uint => VaccineStruct) public vaccineRegisters;
    VaccineStruct[] private vaccines;

    mapping (uint => uint[]) public petVaccinationRegisters;
    VaccinationStruct[] private vaccinations;

    // Adicionar uma nova vacinação
    function addVaccination(address vaccineProvider, address petOwner, uint vaccineId, uint petId) public returns(uint) {
        UserStruct memory user = userAccounts[msg.sender];
        VaccineStruct memory vaccine = vaccineRegisters[vaccineId];

        require ((user.userType == UserType.VET), "Only Vet");
        require ((vaccine.status == VaccineStatus.AVAILABLE), "Unvailable Vaccine");

        uint id = numberOfVaccinations;
        numberOfVaccinations++;
        VaccinationStruct memory vaccination = VaccinationStruct(id, vaccineProvider, petOwner, msg.sender, vaccineId, petId);
        vaccinations.push(vaccination);
        petVaccinationRegisters[petId].push(id);
        vaccineRegisters[vaccineId].status = unmarshalVaccineStatus("UNAVAILABLE");
        return id;
    }

    // Recuperar dados da vacinação pelo id
    function getVaccinationDataById(uint _id) public view returns(uint vaccinationId, address providerVaccine, address petOwner, address vetVaccined, uint vaccineId, uint petId){
        VaccinationStruct memory vaccination = vaccinations[_id];
        require(_id == vaccination.vaccinationId);
        
        vaccinationId = vaccination.vaccinationId;
        providerVaccine = vaccination.providerVaccine;
        vaccineId = vaccination.vaccineId;
        petOwner = vaccination.petOwner;
        vetVaccined = vaccination.vetVaccined;
        petId = vaccination.petId;
    }

    // Adicionar uma nova vacina
    function addVaccine(string memory brand) public returns(uint) {
        UserStruct memory user = userAccounts[msg.sender];
        require ((user.userType == UserType.PROVIDER), "Only Provider");

        uint id = numberOfVaccines;
        numberOfVaccines++;
        VaccineStatus vaccineStatus = unmarshalVaccineStatus("AVAILABLE");

        VaccineStruct memory vaccine = VaccineStruct(id, brand, msg.sender, vaccineStatus);
        vaccines.push(vaccine);
        myVaccines[msg.sender].push(id);
        
        return id;
    }

    // Recuperar vacina por Id
    function getVaccineDataById(uint _id) public view returns(uint vaccineId, string memory brand, address provider){
        VaccineStruct memory vaccine = vaccines[_id];
        require(_id == vaccine.vaccineId);
        require ((_id == myVaccines[msg.sender][_id]), "Only Authorized People");
        vaccineId = vaccine.vaccineId;
        brand = vaccine.brand;
        provider = vaccine.provider;
    }

    // Traduzir status da vacina
    function unmarshalVaccineStatus(string memory _status) private pure returns(VaccineStatus vaccineStatus) {
        bytes32 encodedVaccineStatus = keccak256(abi.encodePacked(_status));
        bytes32 encodedVaccineStatus0 = keccak256(abi.encodePacked("AVAILABLE"));
        bytes32 encodedVaccineStatus1 = keccak256(abi.encodePacked("UNAVAILABLE"));

        if(encodedVaccineStatus == encodedVaccineStatus0) {
            return VaccineStatus.AVAILABLE;
        }
        else if(encodedVaccineStatus == encodedVaccineStatus1) {
            return VaccineStatus.UNAVAILABLE;
        }

        revert("received invalid vaccine status");
        
    }

    // Adicionar um novo usuário
    function addUser(string memory userName, string memory userType) public{
        uint id = numberOfUsers;
        numberOfUsers++;
        UserType userTypeTra = unmarshalUserType(userType);
        UserStruct memory user = UserStruct(id, msg.sender, userName, userTypeTra);
        users.push(user);
        userAccounts[msg.sender] = user;
    }

    // Recuperar dados do usuário pelo endereço
    function getUserDataByAddress(address _user) public view returns(string memory userName, UserType userType){
        UserStruct memory user = userAccounts[_user];
        require(user.userAddress == _user);
        
        userName = user.userName;
        userType = user.userType;
    }

    // Traduzir tipo de usuário
    function unmarshalUserType(string memory _userType) private pure returns(UserType userType) {
        bytes32 encodedUserType = keccak256(abi.encodePacked(_userType));
        bytes32 encodedUserType0 = keccak256(abi.encodePacked("PROVIDER"));
        bytes32 encodedUserType1 = keccak256(abi.encodePacked("VET"));
        bytes32 encodedUserType2 = keccak256(abi.encodePacked("TUTOR"));
        bytes32 encodedUserType3 = keccak256(abi.encodePacked("VERIFIER"));

        if(encodedUserType == encodedUserType0) {
            return UserType.PROVIDER;
        }
        else if(encodedUserType == encodedUserType1) {
            return UserType.VET;
        }
        else if(encodedUserType == encodedUserType2) {
            return UserType.TUTOR;
        }
        else if(encodedUserType == encodedUserType3) {
            return UserType.VERIFIER;
        }

        revert("received invalid user type");
        
    }

    // Recuperar Id's dos pets do tutor logado
    function getPetsByUserLogged() public view returns(uint[] memory){
        return myPets[msg.sender];
    }

    // Permitir ou negar acesso ao pet
    function petPermissionAccess(uint idPet, address vet, bool sendPermission) public returns(bool){
        UserStruct memory userVet = userAccounts[vet];
        require ((userVet.userType == UserType.VET), "Only Vet");
        PetStruct memory pet = pets[idPet];
        require ((msg.sender == pet.petOwner), "Only Pet Owner");

        if(sendPermission){
            myPets[vet].push(idPet);
        }else{
            myPets[vet][idPet] = myPets[vet][myPets[vet].length-1];
            myPets[vet].pop();
        }

        return true;
    }

    function vaccinePermissionAccess(uint vaccineId, address vet) public returns(bool){
        UserStruct memory userVet = userAccounts[vet];
        require ((userVet.userType == UserType.VET), "Only Vet");
        UserStruct memory userProvider = userAccounts[msg.sender];
        require ((userProvider.userType == UserType.PROVIDER), "Only Provider");
        VaccineStruct memory vaccine = vaccineRegisters[vaccineId];
        require ((vaccine.status == VaccineStatus.AVAILABLE), "Unvailable Vaccine");

        myVaccines[vet].push(vaccineId);
        return true;
    }

    // Adicionar um novo pet
    function addPet(string memory _petName) public {
        UserStruct memory user = userAccounts[msg.sender];
        require ((user.userType == UserType.TUTOR), "Only Tutor");

        uint id = numberOfPets;
        numberOfPets++;
        PetStruct memory pet = PetStruct(id, msg.sender, _petName);
        pets.push(pet);
        myPets[msg.sender].push(id);
    }

    // Recuperar pet por Id
    function getPetDataById(uint _id) public view returns(uint petId, address petOwner, string memory petName){
        PetStruct memory pet = pets[_id];
        require(_id == pet.petId);
        require ((_id == myPets[msg.sender][_id]), "Only Authorized People");
        
        petId = pet.petId;
        petOwner = pet.petOwner;
        petName = pet.petName;
    }

    function getPetVaccinationListById(uint _id) public view returns(uint[] memory){
        require ((_id == myPets[msg.sender][_id]), "Only Authorized People");
        return petVaccinationRegisters[_id];
    }

    // Recupera Id's das vacinas que o usuário logado possui acesso
    function getVaccinesByUserLogged() public view returns(uint[] memory){
        return myVaccines[msg.sender];
    }

}