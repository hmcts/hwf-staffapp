'use strict';

window.moj.Modules.JurisdictionModule = {
    init: function(countyJurisdictionId, applicationType) {
        this.countyJurisdictionId = countyJurisdictionId || 1;
        this.applicationType = applicationType;
        this.bindEvents();
        this.loadState();
    },

    bindEvents: function() {
        const jurisdictionRadios = document.querySelectorAll(`#jurisdiction_radios input[name="${this.applicationType}[jurisdiction_id]"]`);

        const self = this;
        jurisdictionRadios.forEach(function (radio) {
            radio.addEventListener('change', function() {
                self.toggleClaimType();
            });
        });
    },

    loadState: function() {
        const countyJurisdictionElement = document.querySelector(`#jurisdiction_${this.countyJurisdictionId}`);
        const formTypeN1Radio = document.querySelector('#form_type_n1_radio');
        const isCountyJurisdiction = countyJurisdictionElement?.checked;
        if (formTypeN1Radio) {
            formTypeN1Radio.disabled = !isCountyJurisdiction;
        }
    },

    toggleClaimType: function() {
        const countyJurisdictionElement = document.querySelector(`#jurisdiction_${this.countyJurisdictionId}`);

        const formTypeN1Radio = document.querySelector('#form_type_n1_radio');
        const claimTypes = [
            ...document.querySelectorAll('[id$="_claim_type_specified"]'),
            ...document.querySelectorAll('[id$="_claim_type_unspecified"]'),
            ...document.querySelectorAll('[id$="_claim_type_personal_injury"]')
        ].filter(el => el.id.match(/^(application|online_application)_claim_type/));

        const isCountyJurisdiction = countyJurisdictionElement?.checked;
        formTypeN1Radio.disabled = !isCountyJurisdiction;
        claimTypes.forEach(claimType => {
            claimType.disabled = !isCountyJurisdiction;
            claimType.checked = false;
        });
    }
};