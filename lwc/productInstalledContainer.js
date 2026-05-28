import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import statusOptions from '@salesforce/apex/ProductInstalledController.statusOptions';
import tensionOptions from '@salesforce/apex/ProductInstalledController.tensionOptions';
import searchProductsByName from '@salesforce/apex/ProductSearchCtrl.searchProductsByName';
import fetchRecordTypeByProduct from '@salesforce/apex/ProductInstalledController.fetchRecordTypeByProduct';
import { labels } from './labels';

export default class ProductInstalledContainer extends LightningElement {

    labels = labels;
    @api productInfo = {};
    @track status = '';
    @track revendedor = '';
    @track numSerie = '';
    @track dataCompraNF = '';
    @track numeroNF = '';
    @track tensão = '';
    @track optionsStatus = [];
    @track optionsTension = [];
    @track valueField;
    @track dealer;
    @track formProductIsValid;
    @track recordTypeIdForCase;
    @track voltageDefault = '220V';

    @track Installed_Product__c = {
        Date_Installed__c: null,
        Serial_Lot_Number__c: null,
        Numero_da_NF__c: null,
        Tensao__c: null,
        Product__c: null,
        Status__c: null,
        Revendedor__c: null,
        
    }

    connectedCallback() {
        this.Installed_Product__c.Status__c = this.labels.LWC_ProductInstalled_Status_Default;
        this.Installed_Product__c.Tensao__c = this.voltageDefault;
    }

    @wire(statusOptions)
    wiredStatusOptions({ error, data }) {
        if (data) {
            this.optionsStatus = data.map(status => ({
                label: status,
                value: status
            }));
        } else if (error) {
            console.error('Erro ao buscar status:', error);
        }
    }

    @wire(tensionOptions)
    wiredtensionOptions({ error, data }) {
        if (data) {
            this.optionsTension = data.map(status => ({
                label: status,
                value: status
            }));
        } else if (error) {
            console.error('Erro ao buscar a tensão:', error);
        }
    }

    @track usualProductsSearch = {};
    @track businessProductsSearch = {};
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

    @track selectedUsualProduct = [];
    @track selectedBusinessProduct = [];
    handleProductSelectionChange(event) {
        if (!event) return;
        event.stopImmediatePropagation();
        const isProductUsualType = event.target.dataset.name == 'UsualProductLookup';
        const productSearchId = event.detail[0];
        if (!productSearchId) {
            if (isProductUsualType) {
                this.handleClearUsualProduct();
                this.setRecordTypeForCase({ productId: null });
            }
            else {
                this.handleClearBusinessProduct();
            }
            this.notifyProductChange();
            return;
        }
        if (isProductUsualType) {
            this.selectedUsualProduct = this.usualProductsSearch.find(product => product.id === productSearchId);
            this.Installed_Product__c = {...this.Installed_Product__c, 'Product__c': productSearchId };
            this.setUsualProductValidation();
            this.setRecordTypeForCase({ productId: productSearchId });
        }
        else {
            this.selectedBusinessProduct = this.businessProductsSearch.find(product => product.id === productSearchId);
            this.Installed_Product__c = {...this.Installed_Product__c, 'Modelo_Comercial__c': productSearchId };
        }
        this.handlerAllFieldsAreValid();
        this.notifyProductChange();
    }

    notifyProductChange() {
        this.productInfo = { 
            ...this.productInfo, 
            'infoNewProductInstalled': this.Installed_Product__c 
        };
        this.dispatchEvent(new CustomEvent('productinfochange', {
            detail: { productInfo: this.productInfo }
        }));
    }

    async setRecordTypeForCase({ productId }) {
        try {
            if (productId) {
                this.recordTypeIdForCase = await fetchRecordTypeByProduct({ productId: productId });
            }
            else {
                this.recordTypeIdForCase = null;
            }
        }
        catch(error) {
            this.recordTypeIdForCase = null;
            this.showErrorToast({ message: error.body.message });
        }
        finally {
            this.notifyRecordTypeChange();
        }
    }

    handleDealer(event) {
        this.dealer = event.detail.recordId;
        this.Installed_Product__c = {...this.Installed_Product__c, 'Revendedor__c': this.dealer };
    }

    handleCompraNF(event) {
        this.dataCompraNF = event.target.value;
        this.Installed_Product__c = {...this.Installed_Product__c, 'Date_Installed__c': this.dataCompraNF };
    }


    handleInputChange(event) {
        const { name, type, checked, value } = event.target;
        this[name] = type === 'checkbox' ? checked : value;

        if( type === 'checkbox') {
            this.valueField = event.target.checked;
        }
        else{
            this.valueField = event.target.value;
        }
        
        this.productInfo = { 
            ...this.productInfo, 
            [event.target.name]: event.target.value 
        };

        let dataName = event.target.dataset.name;

        if (dataName != undefined) this.Installed_Product__c = {...this.Installed_Product__c, [dataName]: this.valueField };

        this.notifyProductChange();
        console.log('productInfo:', JSON.stringify(this.productInfo));
    }

    notifyRecordTypeChange() {
        this.dispatchEvent(new CustomEvent('recordtypeforcasechange', {
            detail: {
                recordTypeId: this.recordTypeIdForCase
            }
        }));
    }

    @api
    handleCreateProductInstalled() {
        saveAccount({ product: this.productInfo.infoNewProductInstalled })
            .then(result => {
                const mgs = result;
                console.log(msg);
            })
            .catch(error => {
                console.error('Erro ao criar conta:', error);
            });
    }

    validateRequiredField(event) {
        let inputField = event.target;
        let fieldValue = inputField.value;

        if (!fieldValue) {
            inputField.setCustomValidity("Este campo é obrigatório.");
            this.formProductIsValid = false;
        } else {
            inputField.setCustomValidity("");
            this.formProductIsValid = true;
        }

        this.productInfo = { 
            ...this.productInfo, 
            'formProductIsValid': this.formProductIsValid 
        };

        event.target.value = fieldValue;
        inputField.reportValidity();

        this.handlerAllFieldsAreValid();
    }

    get missingUsualProductNameMessageError() {
        return this.selectedUsualProduct?.id ? '' : this.labels.LWC_GENERIC_REQUIRED_FIELD;
    }
    get missingUsualProductNameErrors() {
        return this.selectedUsualProduct?.id ? [] : [{id: this.missingUsualProductNameMessageError}];
    }

    @track _hasMissingUsualProductError = true;
    setUsualProductValidation() {
        if (this.selectedUsualProduct?.id) this._hasMissingUsualProductError = false;
        else this._hasMissingUsualProductError = true;
    }

    handleClearUsualProduct() {
        this.selectedUsualProduct = [];
        this.Installed_Product__c['Product__c'] = null;
        this.setUsualProductValidation();
    }

    handleClearBusinessProduct() {
        this.selectedBusinessProduct = [];
        this.Installed_Product__c['Modelo_Comercial__c'] = null;
    }

    showErrorToast({ message }) {
        this.dispatchEvent(new ShowToastEvent({
            title: this.labels.LWC_GENERIC_ERROR,
            variant: 'error',
            message: message,
        }));
    }

    handlerAllFieldsAreValid(){
        this.formProductIsValid = (
            this.Installed_Product__c.Tensao__c != null 
            && this.Installed_Product__c.Product__c != null
            && this.Installed_Product__c.Status__c != null
        );
            
        this.productInfo = { 
            ...this.productInfo, 
            'formProductIsValid': this.formProductIsValid 
        };   

        console.log('productInfo:', JSON.stringify(this.productInfo));
    }

    @api
    resetFields() {
        this.productInfo = {};
        this.dataCompraNF = '';
        this.Installed_Product__c = {
            Date_Installed__c: null,
            Serial_Lot_Number__c: null,
            Numero_da_NF__c: null,
            Product__c: null,
            Revendedor__c: null,   
            Status__c: null,   
            Tensao__c: null,   
        }

        this.handleClearUsualProduct();
        this.Installed_Product__c.Status__c = this.labels.LWC_ProductInstalled_Status_Default;
        this.Installed_Product__c.Tensao__c = this.voltageDefault;    
    }

}