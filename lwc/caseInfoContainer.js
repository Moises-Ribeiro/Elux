import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveTreeCase from '@salesforce/apex/CaseInfoContainerController.saveTreeCase';
import originOptions from '@salesforce/apex/CaseInfoContainerController.originOptions';
import getResponsableTeamOptions from '@salesforce/apex/CaseInfoContainerController.getResponsableTeamOptions';
import getResponsableSectorOptions from '@salesforce/apex/CaseInfoContainerController.getResponsableSectorOptions';
import getCaseStatusOptions from '@salesforce/apex/CaseInfoContainerController.getCaseStatusOptions';
import getSummaryCaseRecordTypeId from '@salesforce/apex/CaseInfoContainerController.getSummaryCaseRecordTypeId';
import reasonForClose from '@salesforce/apex/CaseInfoContainerController.reasonForClose';
import getPicklistItemsByIndex from '@salesforce/apex/PicklistHelper.getPicklistItemsByIndex';
import searchProductsByName from '@salesforce/apex/ProductSearchCtrl.searchProductsByName';
import fetchRecordTypeByProduct from '@salesforce/apex/ProductInstalledController.fetchRecordTypeByProduct';
import { labels } from './labels';

const MAPPING_OPTIONS = {
    ByValue: 'BY_VALUE',
    ByLabel: 'BY_LABEL'
};

export default class CaseInfoContainer extends NavigationMixin(LightningElement) {

    labels;
    recordTypeIdSummaryCase;
    @track accountInfo = {};
    @track infoNewProductInstalled;
    @track labels = {};
    @track productInfo = {};
    @track premise = {};
    @track currentStoredPremise = {};
    @track caseStatusOptions = [];
    @track origin = [];
    @track responsableSectorOptions = [];
    @track responsableTeamOptions = [];
    @track reasonForCloseSelector = [];
    @track product = '';
    @track valueField = '';
    @track recebimento = '';
    @track caseIdByMessage = [];
    @track isInitialLoading = false;
    @track _isSaveDisabled = true;
    @track isNotValidAccount = true;
    @track isNotValidProduct = true;
    @track isNotValidCase = true;
    @track usualProductsSearch = {};
    @track businessProductsSearch = {};
    @track selectedUsualProduct = [];

    @track Case = {
        status_do_caso__c: null,
        Motivo_de_encerramento__c: null,
        Produto_revenda__c: null,
        Origin: null,
        Recebimento__c: null,
        Equipe__c: null,
        InitialCustomerReport__c: null,
        ResponsibleSector__c: null,
        RecordTypeId: null
    }

    renderedCallback() {
        this._isSaveDisabled = this.isSaveDisabled;
    }

    connectedCallback() {
        this.labels = labels;
        this.fetchPicklistOptions();
        this.Case.status_do_caso__c = this.labels.LWC_Case_StatusCase_Default;
        console.log('[CaseSection][connectedCallback] CaseOrigin => ', this.Case.Origin);
        this.getRecordTypeIdSummaryCase();
    }

    getRecordTypeIdSummaryCase() {
        getSummaryCaseRecordTypeId()
            .then(result => {
                this.recordTypeIdSummaryCase = result;
            })
            .catch(error => {
                console.error('Erro ao buscar RecordTypeId do caso resumido:', error);
            });
    }

    get isDisabledCaseStatus() {
        return !this.Case?.Equipe__c;
    }

    fetchPicklistOptions() {
        this.getStatePicklistOptions();
        this.getCountryPicklistOptions();
        this.getResponsableTeamOptions();
        this.getResponsableSectorOptions();
        this.getCaseStatusOptions();
    }
    
    async getResponsableTeamOptions() {
        try {
            this.responsableTeamOptions = await getResponsableTeamOptions();
        }
        catch(error) {
            this.showErrorToast({ message: this.extractErrorMessage(error) });
        }
    }

    async getResponsableSectorOptions() {
        try {
            this.responsableSectorOptions = await getResponsableSectorOptions();
        }
        catch(error) {
            this.showErrorToast({ message: this.extractErrorMessage(error) });
        }
    }

    async getCaseStatusOptions() {
        try {
            this.caseStatusOptions = await getCaseStatusOptions();
            this.Case.status_do_caso__c = this.labels.LWC_Case_StatusCase_Default;
        }
        catch(error) {
            this.showErrorToast({ message: this.extractErrorMessage(error) });
        }
    }

    @wire(originOptions)
        wiredoriginOptions({ error, data }) {
            if (data) {
                this.origin = data.map(origin => ({
                    label: origin,
                    value: origin
                }));
            } else if (error) {
                console.error('Erro ao buscar o canal:', error);
            }
        }

    @wire(reasonForClose)
        wiredReasonForClose({ error, data }) {
            if (data) {
                this.reasonForCloseSelector = data.map(reasonForCloseSelector => ({
                    label: reasonForCloseSelector,
                    value: reasonForCloseSelector
                }));
            } else if (error) {
                console.error('Erro ao buscar o responsável:', error);
            }
        }

    handleProduct(event) {
        this.product = event.detail.recordId;
        this.Case = {...this.Case, 'Product__c': this.product };
    }
        
    handleRecebimento(event) {
        this.recebimento = event.target.value;
        if (!this.recebimento) {
            this.Case = { ...this.Case, 'Recebimento__c': null };
        }
        else {
            const dateOfReceipt = new Date(event.target.value)?.toISOString();
            this.Case = { ...this.Case, 'Recebimento__c': dateOfReceipt };
        }
    }

    handleRecordTypeForCaseChange(event) {
        const caseRecordTypeId = event.detail.recordTypeId;
        this.Case.RecordTypeId = caseRecordTypeId;
        console.log('[CaseSection][handleRecordTypeForCaseChange] recTypeOnCase ==> ', caseRecordTypeId);
        this._isSaveDisabled = this.isSaveDisabled;
    }

    handleAccountInfoChange(event) {
        this.accountInfo = event.detail.accountInfo;
        console.log('[CaseSection][handleAccountInfoChange] this.accountInfo ==>', JSON.stringify(this.accountInfo)); 
        
        if (this.accountInfo.formAccountIsValid) {
            this.isNotValidAccount = false;
        }
        else {
            this.isNotValidAccount = true;
        }

        if (this.accountInfo.casoResumido) {
            this.infoNewProductInstalled = {};
            this.Case = { ...this.Case, RecordTypeId: this.recordTypeIdSummaryCase, Top_Level_DSM__c: null };
        }
        
        if (!this.accountInfo.casoResumido) {
            this.Case.Produto_revenda__c = null;
            this.selectedUsualProduct = [];
            this.Case = { ...this.Case, Motivo_de_encerramento__c: null };
        }
        this._isSaveDisabled = this.isSaveDisabled;
    }

    handleProductInfoChange(event) {
        this.productInfo = event.detail.productInfo;
        this.infoNewProductInstalled = this.productInfo.infoNewProductInstalled;
        console.log('[CaseSection][handleProductInfoChange] this.productInfo ==> ', JSON.stringify(this.productInfo));
        console.log('[CaseSection][handleProductInfoChange] this.infoNewProductInstalled ==> ', JSON.stringify(this.infoNewProductInstalled));

        if (this.productInfo.formProductIsValid) {
            this.isNotValidProduct = false;
        }
        else {
            this.isNotValidProduct = true;
        }

        this._isSaveDisabled = this.isSaveDisabled;

    }

    handleInputChange(event){
        const { name, type, checked, value } = event.target;
        this[name] = type === 'checkbox' ? checked : value;

        if( type === 'checkbox') {
            this.valueField = event.target.checked;
        }
        else{
            this.valueField = event.target.value;
        }

        let dataName = event.target.dataset.name;

        if(dataName != undefined) this.Case = {...this.Case, [dataName]: this.valueField }

        console.log('[CaseSection][handleInputChange] this.Case', JSON.stringify(this.Case));
        this._isSaveDisabled = this.isSaveDisabled;

    }

    get isValidPremiseAddress() {
        return this.changedPremise
            && Object.keys(this.changedPremise)?.length > 0
            && !this.changedPremise?.hasInputErrors;
    }
    get isNotValidPremiseAddress() {
        return !this.isValidPremiseAddress;
    }

    handleOnAddressChange(event) {
        this.changedPremise = event.detail;
        this._isSaveDisabled = this.isSaveDisabled;
        console.log('[CaseSection][handleOnAddressChange] this.changedPremise ==> ', JSON.stringify(event.detail));
    }

    showSuccessToast({ message }) {
        this.dispatchEvent(new ShowToastEvent({
            title: this.labels.LWC_GENERIC_ERROR,
            variant: 'success',
            message: message,
        }));
    }

    showErrorToast({ message }) {
        this.dispatchEvent(new ShowToastEvent({
            title: this.labels.LWC_GENERIC_ERROR,
            variant: 'error',
            message: message,
        }));
    }

    async handleSaveTreeCase() {
        if (this.isNotValidPremiseAddress) {
            this.showErrorToast({ message: this.labels.LWC_CHECK_FOR_ERRORS_IN_THE_ADDRESS_SECTION });
            return;
        }

        let _postalCode = JSON.stringify(this.changedPremise?.address.Endereco__PostalCode__s);
        let _logradouro = JSON.stringify(this.changedPremise?.address.Endereco__Street__s);
        let _numero = JSON.stringify(this.changedPremise?.address.Numero__c);
        let _bairro = JSON.stringify(this.changedPremise?.address.Bairro__c);
        let _cidade = JSON.stringify(this.changedPremise?.address.Endereco__City__s);
        let _estado = JSON.stringify(this.changedPremise?.address.Endereco__StateCode__s);
        let _enderecoPrincipal = JSON.stringify(this.changedPremise?.address.Endereco_Principal__c);
        let _ativo = JSON.stringify(this.changedPremise?.address.Ativo__c);
        let _enderecoContryCode = JSON.stringify(this.changedPremise?.address.Endereco__CountryCode__s);
        let _conta = JSON.stringify(this.changedPremise?.address.Conta__c);
        let _proximidade = JSON.stringify(this.changedPremise?.address.Proximidade__c);
        let _complemento = JSON.stringify(this.changedPremise?.address.Complemento__c);

        _postalCode = _postalCode?.replace(/^"|"$/g, '');
        _logradouro = _logradouro?.replace(/^"|"$/g, '');
        _numero = _numero?.replace(/^"|"$/g, '');
        _bairro = _bairro?.replace(/^"|"$/g, '');
        _cidade = _cidade?.replace(/^"|"$/g, '');
        _estado = _estado?.replace(/^"|"$/g, '');
        _enderecoPrincipal = _enderecoPrincipal?.replace(/^"|"$/g, '');
        _ativo = _ativo?.replace(/^"|"$/g, '');
        _enderecoContryCode = _enderecoContryCode?.replace(/^"|"$/g, '');
        _conta = _conta?.replace(/^"|"$/g, '');
        _proximidade = _proximidade?.replace(/^"|"$/g, '');
        _complemento = _complemento?.replace(/^"|"$/g, '');

        const _premise = {
            Endereco__PostalCode__s: _postalCode,
            Endereco__Street__s: _logradouro,
            Numero__c: _numero,
            Bairro__c: _bairro,
            Endereco__City__s: _cidade,
            Endereco__StateCode__s: _estado,
            Endereco_Principal__c: _enderecoPrincipal,
            Ativo__c: _ativo,
            Endereco__CountryCode__s: _enderecoContryCode,
            Conta__c: _conta,
            Proximidade__c: _proximidade,
            Complemento__c: _complemento
        };

        const enrichedAccount = { ...this.accountInfo.infoNewAccount, ...this.buildAccountAddress({ premise: _premise }) };
        
        this.accountInfo = { ...this.accountInfo, infoNewAccount: enrichedAccount  };

        this.isInitialLoading = true;
        try {
            const treeCase = await saveTreeCase({ account: this.accountInfo.infoNewAccount, product: this.infoNewProductInstalled , caseInfo: this.Case, premise: _premise  })
            if(treeCase){
                this.caseIdByMessage = Object.entries(treeCase).map(([key, value]) => {
                    return { key, value };
                });

                if (this.caseIdByMessage[0].key == 'success') {
                    this.handleCaseRedirect({ caseId: this.caseIdByMessage[0]?.value });
                    this.hancleClearChildFields();
                }
            }
        }
        catch(error) {
            console.log('[Error][CaseSection] this.caseIdByMessage => ', JSON.stringify(this.caseIdByMessage));
            
            if (Object.keys(error).length === 0) {
                this.handleCaseRedirect({ caseId: this.caseIdByMessage[0]?.value });
                return;
            }
            console.error('Erro ao criar caso => ', JSON.stringify(error));
            this.isInitialLoading = false;
            this.showErrorToast({ message: this.extractErrorMessage(error) });
        }
        finally {
            this.isInitialLoading = false;
        }
    }

    extractErrorMessage(error) {
        try {
            if (error.body && error.body.fieldErrors) {
                const fieldErrors = error.body.fieldErrors;
                for (let field in fieldErrors) {
                    if (fieldErrors[field].length > 0) {
                        return fieldErrors[field][0].message;
                    }
                }
            }
            return error.body.message;
        } catch (e) {
            return error.body.message;
        }
    }

    @track stateNamesByCode = {};
    async getStatePicklistOptions() {
        await getPicklistItemsByIndex({
            targetObject: 'Premise__c',
            targetField: 'Endereco__StateCode__s',
            mappingOption: MAPPING_OPTIONS.ByValue
        }).then(stateNamesByCode => {
            this.stateNamesByCode = stateNamesByCode;
        });
    }

    @track countryNamesByCode = {};
    async getCountryPicklistOptions() {
        await getPicklistItemsByIndex({
            targetObject: 'Premise__c',
            targetField: 'Endereco__CountryCode__s',
            mappingOption: MAPPING_OPTIONS.ByValue
        }).then(countryNamesByCode => {
            this.countryNamesByCode = countryNamesByCode;
        });
    }

    buildAccountAddress({ premise }) {
        let street = premise?.Endereco__Street__s + ', ' + premise?.Numero__c;
        if (premise?.Complemento__c) street += ' ' + premise?.Complemento__c;
        return {
            'BillingCity': premise?.Endereco__City__s,
            'BillingCountry': this.countryNamesByCode[premise?.Endereco__CountryCode__s],
            'BillingState':  premise?.Endereco__StateCode__s,
            'BillingStreet': street,
            'BillingPostalCode': premise?.Endereco__PostalCode__s,
            'Bairro__c': premise?.Bairro__c,
            'Proximidade__c': premise?.Proximidade__c
        }
    }

    handleCaseRedirect({ caseId }) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view',
            }
        });
    }

    validateRequiredField(event) {
        let inputField = event.target;
        let fieldValue = inputField.value;

        if (!fieldValue) {
            inputField.setCustomValidity("Este campo é obrigatório.");
            this.isNotValidCase = true;
        } else {
            inputField.setCustomValidity("");
            this.isNotValidCase = false;
        }

        event.target.value = fieldValue;
        inputField.reportValidity();

        console.log('[CaseSection] isNotValidPremiseAddress ==>', this.isNotValidPremiseAddress);
        console.log('[CaseSection] isNotValidAccount ==>', this.isNotValidCurrentAccount);
        console.log('[CaseSection] isNotValidProduct ==>', this.isNotValidCurrentProduct);
        console.log('[CaseSection] isNotValidCase ==>', this.isNotValidCurrentCase);
    }

    async handleProductSearch(event) {
        const lookupElement = event.target;
        const isProductUsualType = lookupElement.dataset.name == 'UsualProductLookup';
        try {
            const productResults = await searchProductsByName({ productName: event.detail.searchTerm });
            if (isProductUsualType) {
                this.usualProductsSearch = productResults;
            }
            else {
                this.businessProductsSearch = productResults;
            }
            lookupElement.setSearchResults(productResults);
        }
        catch(error) {
        }
    }

    handleProductSelectionChange(event) {
        if (!event) return;
        event.stopImmediatePropagation();
        const isProductUsualType = event.target.dataset.name == 'UsualProductLookup';
        const productSearchId = event.detail[0];
        if (!productSearchId) {
            
            this.selectedUsualProduct = [];
            this.Case.Produto_revenda__c = null;
            this.infoNewProductInstalled = {};
            return;
        }
        if (isProductUsualType) {
            this.selectedUsualProduct = this.usualProductsSearch.find(product => product.id === productSearchId);
            this.infoNewProductInstalled = {...this.infoNewProductInstalled, 'Product__c': productSearchId };

        }

        this.Case.Produto_revenda__c = productSearchId;
        this.Case.RecordTypeId = this.recordTypeIdSummaryCase;
        
    }

    async setRecordTypeForCase({ productId }) {
       
        let recordTypeIdForCase = null; 
        try {
            
            if (productId) {
                recordTypeIdForCase = await fetchRecordTypeByProduct({ productId: productId });
            }
            else {
                recordTypeIdForCase = null;
            }
        }
        catch(error) {
            recordTypeIdForCase = null;
            this.showErrorToast({ message: error.body.message });
        }
        finally {
            this.Case.RecordTypeId = recordTypeIdForCase;
            console.log('infoNewProductInstalled: ', JSON.stringify(this.infoNewProductInstalled));
        }
    }

    handleClearUsualProduct() {
        this.selectedUsualProduct = [];
        this.infoNewProductInstalled = {...this.infoNewProductInstalled, 'Product__c': null };
    }

    hancleClearChildFields() {
        const accountComp = this.template.querySelector('c-account-info-container');
        const productComp = this.template.querySelector('c-product-installed-container');

        if (accountComp) {
            accountComp.resetFields();
        }

        if (productComp) {
            productComp.resetFields();
        }

        this.handleClearFieldsCase();
    }

    handleClearFieldsCase() {
        this.recebimento = null;
        this.Case = {
            status_do_caso__c: null,
            Motivo_de_encerramento__c: null,
            Produto_revenda__c: null,
            Origin: null,
            Recebimento__c: null,
            Equipe__c: null,
            InitialCustomerReport__c: null,
            ResponsibleSector__c: null,
            RecordTypeId: null
        }
        this.selectedUsualProduct = [];
        this.Case.status_do_caso__c = this.labels.LWC_Case_StatusCase_Default;
    }

    get isSaveDisabled() {
        if (this.isNotValidCurrentAccount) {
            console.log('------- isNotValidCurrentAccount ------[START]');
            console.log('==> ', JSON.stringify(this.accountInfo));
            console.log('------- isNotValidCurrentAccount ------[END]\n');
        }
        if (this.isNotValidCurrentProduct) {
            console.log('------- isNotValidCurrentProduct ------[START]');
            console.log('==> ', JSON.stringify(this.infoNewProductInstalled));
            console.log('------- isNotValidCurrentProduct ------[END]\n');
        }
        if (this.isNotValidCurrentCase) {
            console.log('------- isNotValidCurrentCase ------[START]');
            console.log('[accountInfo]==> ', JSON.stringify(this.accountInfo));
            console.log('[case]==> ', JSON.stringify(this.Case));
            console.log('------- isNotValidCurrentCase ------[END]\n');
        }
        if (this.isNotValidPremiseAddress) {
            console.log('------- isNotValidPremiseAddress ------[START]');
            console.log('==> ', JSON.stringify(this.changedPremise));
            console.log('------- isNotValidPremiseAddress ------[END]\n');
        }
        return this.isNotValidCurrentAccount
            || this.isNotValidCurrentProduct
            || this.isNotValidCurrentCase
            || this.isNotValidPremiseAddress;
    }

    get isNotValidCurrentCase() {
        const isNotValidFullCase = !this.Case?.Origin
            || !this.Case?.status_do_caso__c
            || !this.Case?.Equipe__c
            || !this.Case?.ResponsibleSector__c
            || !this.Case?.InitialCustomerReport__c
            || !this.Case?.RecordTypeId;
        if (!this.accountInfo.casoResumido) {
            return isNotValidFullCase;
        }
        return isNotValidFullCase || !this.Case?.Motivo_de_encerramento__c;
    }

    get isNotValidCurrentProduct() {
        if(this.accountInfo.casoResumido) return false;
        return !this.infoNewProductInstalled?.Product__c
            || !this.infoNewProductInstalled?.Status__c
            || !this.infoNewProductInstalled?.Tensao__c;
    }

    get isNotValidCurrentAccount() {
        if (this.accountInfo?.persona == 'pessoaFisica') {
            return !this.accountInfo?.infoNewAccount?.FirstName
                || !this.accountInfo?.infoNewAccount?.LastName
                || !this.accountInfo?.infoNewAccount?.CPF__c
                || !this.accountInfo?.infoNewAccount?.Phone;
        }
        else if (this.accountInfo?.persona == 'pessoaJuridica') {
            return !this.accountInfo?.infoNewAccount?.Name
                || !this.accountInfo?.infoNewAccount?.CNPJ__c
                || !this.accountInfo?.infoNewAccount?.Phone;
        }
        return true;
    }

}