'use strict';

window.moj.Modules.JurisdictionModule = {
    init: function(countyJurisdictionId) {
        this.countyJurisdictionId = countyJurisdictionId || 1;
        this.bindEvents();
        this.loadState();
    },

    bindEvents: function() {
        const jurisdictionRadios = document.querySelectorAll('#jurisdiction_radios input[name="application[jurisdiction_id]"]');
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
        const otherRadioRadio = document.querySelector('#other_radio');
        const claimTypes = [
            document.querySelector('#application_claim_type_specified'),
            document.querySelector('#application_claim_type_unspecified'),
            document.querySelector('#application_claim_type_personal_injury')
        ];

        const isCountyJurisdiction = countyJurisdictionElement?.checked;
        formTypeN1Radio.disabled = !isCountyJurisdiction;

        claimTypes.forEach(claimType => {
            claimType.disabled = !isCountyJurisdiction;
            claimType.checked = false;
        });
    }
};