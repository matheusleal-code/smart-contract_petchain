pragma solidity >=0.7.0 <0.9.0;

contract PetChain {

    uint public numberOfPets;
    uint public numberOfUsers;
    uint public numberOfVaccines;
    uint public numberOfVaccinations;

    // Tipos de usuários -> Provedor da vacina, Veterinário, Tutor, Verificador
    enum UserType { PROVIDER, VET, TUTOR, VERIFIER}

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

    // Estrutura - Vacina
    struct VaccineStruct {
        uint vaccineId;
        string brand;
        address provider;
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

    mapping (address => uint) public userAccounts;
    UserStruct[] private users;

    VaccineStruct[] private vaccines;

    mapping (uint => uint[]) public petVaccinationRegisters;
    VaccinationStruct[] private vaccinations;


    // Adicionar uma nova vacinação
    function addVaccination(address providerVaccine, address petOwner, address vetVaccined, uint vaccineId, uint petId) public returns(uint) {
        uint id = numberOfVaccinations;
        numberOfVaccinations++;
        VaccinationStruct memory vaccination = VaccinationStruct(id, providerVaccine, petOwner, vetVaccined, vaccineId, petId);
        vaccinations.push(vaccination);
        petVaccinationRegisters[petId].push(id);
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
        uint id = numberOfVaccines;
        numberOfVaccines++;
        VaccineStruct memory vaccine = VaccineStruct(id, brand, msg.sender);
        vaccines.push(vaccine);
        
        return id;
    }

    // Recuperar vacina por Id
    function getVaccineDataById(uint _id) public view returns(uint vaccineId, string memory brand, address provider){
        VaccineStruct memory vaccine = vaccines[_id];
        require(_id == vaccine.vaccineId);
        
        vaccineId = vaccine.vaccineId;
        brand = vaccine.brand;
        provider = vaccine.provider;
    }

    // Adicionar um novo usuário
    function addUser(string memory userName, string memory userType) public{
        uint id = numberOfUsers;
        numberOfUsers++;
        UserType userTypeTra = unmarshalUserType(userType);
        UserStruct memory user = UserStruct(id, msg.sender, userName, userTypeTra);
        users.push(user);
        userAccounts[msg.sender] = id;
    }

    // Recuperar dados do usuário pelo endereço
    function getUserDataByAddress(address user) public view returns(string memory userName, UserType userType){
        uint id = userAccounts[user];
        userName = users[id].userName;
        userType = users[id].userType;
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
    function getPetIdsByTutor() public view returns(uint[] memory){
        return myPets[msg.sender];
    }

    // Adicionar um novo pet
    function addPet(string memory _petName) public {
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
        
        petId = pet.petId;
        petOwner = pet.petOwner;
        petName = pet.petName;
    }

    function getPetVaccinationListById(uint _id) public view returns(uint[] memory){
        return petVaccinationRegisters[_id];
    }

}