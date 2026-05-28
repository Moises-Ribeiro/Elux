import { LightningElement, track, api, wire } from 'lwc';
import loadTreatment from '@salesforce/apex/AccountInfoContainerController.loadTreatment';
import saveAccount from '@salesforce/apex/AccountInfoContainerController.saveAccount';
import getCurrentUser from '@salesforce/apex/CustomSearchAddressCtrl.getCurrentUser';
import { labels } from './labels';
import userLang from '@salesforce/i18n/lang';

const COUNTRIES_WITH_ADDRESS_FORMAT_LIKE_BRAZIL = ['Brasil'];

export default class AccountInfoContainer extends LightningElement {

    labels = labels;
    language = userLang;

    @api accountInfo = {};
    @api currentStoredPremise = {};

    @track contactAccount= false;
    @track caseSummarized = false;
    @track selectedPersona = ''; 
    @track ispersonaJuridica; 
    @track ispersonaFisica = true;
    @track valueField;
    @track salutationOptions = [];
    @track formAccountIsValid = false;
    @track showFirstNameError = false;
    @track Account = {}
    @track isAddressFormatLikeBrazil = false;
    @track isAddressComponentLoading = true;
    @track isphonewhatsapp = true;
    @track isAgregateContat = true; 

    async connectedCallback() {
        await getCurrentUser()
        .then(currentUser => {
            this.isAddressFormatLikeBrazil =
                COUNTRIES_WITH_ADDRESS_FORMAT_LIKE_BRAZIL.includes(currentUser?.PaisAtribuidoUser__c);
            this.accountInfo = { ...this.accountInfo, 'persona': 'pessoaFisica' };
        })
        .catch(error => {
        })
        .finally(() => {
            this.isAddressComponentLoading = false;
        });
    }

    @wire(loadTreatment)
    wiredSalutations({ error, data }) {
        if (data) {
            this.salutationOptions = data.map(value => ({ label: value, value: value }));
        } else if (error) {
            console.error('Erro ao buscar os valores:', error);
        }
    }
     
    @track casoResumido = false;
    handleInputChange(event) {
        const { name, type, checked, value } = event.target;
        this[name] = type === 'checkbox' ? checked : value;
        this.selectedPersona = event.target.label;

        const casoResumido = this.casoResumido;

        if( type === 'checkbox') {
            this.valueField = event.target.checked;
        }
        else{
            this.valueField = event.target.value;
        }

        if(event.target.value == 'pessoaJuridica') {
            this.ispersonaJuridica = true;
            this.ispersonaFisica = false;
            this.isphonewhatsapp = true;
            this.isAgregateContat = true;
            this.Account = {};
            this.accountInfo = {};
            this.accountInfo = { 
                ...this.accountInfo, 
                'persona': 'pessoaFisica',
                'casoResumido': casoResumido 
            }; 
             
        }

        if(event.target.value == 'pessoaFisica') {
            this.ispersonaFisica = true; 
            this.ispersonaJuridica = false;
            this.contactAccount = false;
            this.isphonewhatsapp = true;
            this.isAgregateContat = true;
            this.Account = {};
            this.accountInfo = {};
            this.accountInfo = { 
                ...this.accountInfo, 
                'persona': 'pessoaJuridica', 
                'casoResumido': casoResumido
            };  

        }
        
        this.accountInfo = { 
            ...this.accountInfo, 
            [event.target.name]: this.valueField 
        };

        Object.keys(this.Account).forEach(key => {
            if (this.Account[key] === '') {
                delete this.Account[key];
            }
        });

        let dataName = event.target.dataset.name;

        if(dataName != undefined) this.Account = {...this.Account, [dataName]: this.valueField }

        this.accountInfo = { 
            ...this.accountInfo, 
            'infoNewAccount': this.Account, 
            'formAccountIsValid': this.formAccountIsValid 
        };

        console.log('accountInfo:', JSON.stringify(this.accountInfo));
        console.log('account:', JSON.stringify(this.Account));

        this.accountInfo = { ...this.accountInfo, 'persona': this.currentAccountType };
        const eventDetail = { accountInfo: this.accountInfo };
        const customEvent = new CustomEvent('accountinfochange', {
            detail: eventDetail
        });

        this.dispatchEvent(customEvent);
    }

    get currentAccountType() {
        return this.isCheckedPersonalAccount ? 'pessoaFisica' : 'pessoaJuridica';
    }

    get isCheckedPersonalAccount() {
        let personalAccountCheckBox = this.template.querySelector('[data-name="persona"]');
        return personalAccountCheckBox?.checked;
    }

    handleOnAddressChange(event) {        
        this.dispatchEvent(new CustomEvent('addresschange', {
            detail: event.detail
        }));
    }

    @api
    handleCreateAccount() {
        saveAccount({ account: this.Account })
            .then(result => {
                const mgs = result;
                console.log(msg);
            })
            .catch(error => {
                console.error('Erro ao criar conta:', error);
            });
    }
    
    validateRequiredField(event) {
        const inputField = event.target;
        const fieldName = inputField.name;
        let fieldValue = inputField.value.trim();

        if (!fieldValue) {
            inputField.setCustomValidity("Este campo é obrigatório.");
            this.formAccountIsValid = false;
           
        } else {
            inputField.setCustomValidity("");
            this.formAccountIsValid = true;
            
        }
        inputField.reportValidity();

         this.accountInfo = { 
            ...this.accountInfo, 
            'formAccountIsValid': this.formAccountIsValid
        };

        fieldValue = fieldValue.replace(/\D/g, '');

        if(this.language == 'pt-BR') {

            fieldValue = fieldValue.replace(/^(\d{3})(\d)/, '$1.$2');
            fieldValue = fieldValue.replace(/^(\d{3})\.(\d{3})(\d)/, '$1.$2.$3');
            fieldValue = fieldValue.replace(/\.(\d{3})(\d)/, '.$1-$2');
        }
        
        this.Account.CPF__c = fieldValue;
        this.Account = {...this.Account, 'CPF__c': fieldValue }

        this.handlerAllFieldsAreValid();

        
    }

    validateRequiredFieldPJ(event) {
        const inputField = event.target;
        const fieldName = inputField.name;
        let fieldValue = inputField.value.trim();

        if (!fieldValue) {
            inputField.setCustomValidity("Este campo é obrigatório.");
            this.formAccountIsValid = false
           
        } else {
            inputField.setCustomValidity("");
            this.formAccountIsValid = true;
            
        }
        inputField.reportValidity();

        this.accountInfo = { 
            ...this.accountInfo, 
            'formAccountIsValid': this.formAccountIsValid 
        };


        fieldValue = fieldValue.replace(/\D/g, '');

        if(this.language == 'pt-BR') {

            fieldValue = fieldValue.replace(/^(\d{2})(\d)/, '$1.$2');
            fieldValue = fieldValue.replace(/^(\d{2})\.(\d{3})(\d)/, '$1.$2.$3');
            fieldValue = fieldValue.replace(/\.(\d{3})(\d)/, '.$1/$2');
            fieldValue = fieldValue.replace(/(\d{4})(\d)/, '$1-$2');

        }

        this.Account.CNPJ__c = fieldValue;
        this.Account = {...this.Account, 'CNPJ__c': fieldValue }


        this.handlerAllFieldsAreValid();
        
    }

    validateRequiredFieldPhone(event) {
        let inputField = event.target;
        let fieldValue = inputField.value.trim();

        fieldValue = fieldValue.replace(/\D/g, '');

        if (!fieldValue) {
            inputField.setCustomValidity("Este campo é obrigatório.");
            this.formAccountIsValid = false;
        } else {
            inputField.setCustomValidity("");
            this.formAccountIsValid = true;
        }

        this.accountInfo = { 
            ...this.accountInfo, 
            'formAccountIsValid': this.formAccountIsValid 
        };

        event.target.value = fieldValue;
        inputField.reportValidity();
    }

    validateRequiredFieldNome(event) {
        let inputField = event.target;
        let fieldValue = inputField.value.trim();

        if (!fieldValue) {
            inputField.setCustomValidity("Este campo é obrigatório.");
            this.formAccountIsValid = false;
        } else {
            inputField.setCustomValidity("");
            this.formAccountIsValid = true;
        }

        this.accountInfo = { 
            ...this.accountInfo, 
            'formAccountIsValid': this.formAccountIsValid 
        };

        event.target.value = fieldValue;
        inputField.reportValidity();
    }

    handlerAllFieldsAreValid(){

        if(this.ispersonaJuridica){

            this.formAccountIsValid = (this.Account.Name != ""  && this.Account.CNPJ__c != "" && this.Account.Phone != "");
            
            this.accountInfo = { 
                ...this.accountInfo, 
                'formAccountIsValid': this.formAccountIsValid 
            };   

        }
        else if(this.ispersonaFisica){

            this.formAccountIsValid = (
                this.Account.FirstName != ""
                && this.Account.LastName != ""
                && this.Account.CPF__c != ""
                && this.Account.Phone != ""
            );

            this.accountInfo = { 
                ...this.accountInfo, 
                'formAccountIsValid': this.formAccountIsValid
            };

        }

    }

    @api
    resetFields() {

        this.accountInfo = {};
        this.Account = {
            Saluation: '',
            FirstName: '',
            LastName: '',
            Name:'',
            CNPJ__c:'',
            CPF__c:'',
            Phone:'',
            Telefone_2__c:'',
            Falar_com__c:'',
            Telefone_3__c:'',
            PersonEmail:'',
            E_Mail__c:'',
            PersonMobilePhone:''
        }

        const _searchAddress = this.template.querySelector('c-search-address');
        const _searchAddressCustom = this.template.querySelector('c-custom-search-address');
        const _searchResult = _searchAddress != null ? _searchAddress : _searchAddressCustom;

        if (_searchResult) {
            _searchResult.resetFields();
        }   
    }

}