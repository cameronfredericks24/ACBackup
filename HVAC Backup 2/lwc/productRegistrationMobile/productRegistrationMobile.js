import { LightningElement, track } from 'lwc';

export default class ProductRegistrationMobile extends LightningElement {


    @track assetDetails = [];

   

    connectedCallback(){
        
        this.assetDetails = [
            {
                "INVOICE_NUMBER": "2161082156",
                "INVOICE_DATE": "2022-11-09",
                "CUSTOMER_CODE": "03008204",
                "DEPARTMENT": "30",
                "BRANCH_CODE": "216",
                "PRODUCT": [
                    {
                        "ZIS_INSTALLABLE": "true",
                        "MODEL_CODE": "DPA1983R1",
                        "SERIAL_NUMBER": "",
                        "MANUFACTURING_DATE": "",
                        "SUBCOMPONENT": []
                    }
                ],
                "CHILD_PRODUCTS": [
                    {
                        "ZIS_INSTALLABLE": "false",
                        "MODEL_CODE": "DPA661-O",
                        "SERIAL_NUMBER": "DPA661-OKVF02469",
                        "MANUFACTURING_DATE": "2022-10-28",
                        "SUBCOMPONENT": [
                            {
                                "MODEL_CODE": "BFAX-GID018-00",
                                "SERIAL_NUMBER": "AB24X3ACW2229306"
                            },
                            {
                                "MODEL_CODE": "COCD-3021836000-01",
                                "SERIAL_NUMBER": "COCD-3021836000-01-R00102207242"
                            },
                            {
                                "MODEL_CODE": "FBOT-GD555-50",
                                "SERIAL_NUMBER": "SAEDPA721092202041"
                            },
                            {
                                "MODEL_CODE": "MOAC-F007016-014",
                                "SERIAL_NUMBER": "I22C395T20753"
                            }
                        ]
                    },
                ]
            }
        ];
    }

}