import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import KnowledgeArticles from '@salesforce/apex/knowledgeSearchController.getKnowledgeArticles';

export default class KnowledgeSearch extends NavigationMixin(LightningElement) {
    @track article;
    @track data = [];
    @api recordId;
    error;

    connectedCallback() {
        // Fetch initial data when the component is initialized
        this.fetchArticles();
    }

fetchArticles() {
    if (this.article) {
        KnowledgeArticles({ searchText: this.article })
            .then(result => {
                this.data = result.map(article => {
                    let answer = article.Answer__c || 'Answer Not Available';
                    let showAnswerNotAvailable = true;
                    
                    // Check for "Error" record type
                    if (article.RecordType && article.RecordType.Name === 'Error') {
                        answer = article.Answer__c || '';
                        showAnswerNotAvailable = false;
                    }

                    // Check for "Procedure" record type and blank Procedure_Steps__c
                    if (article.RecordType && article.RecordType.Name === 'Procedure') {
                        if (!article.Procedure_Steps__c) {
                            answer = 'Answer Not Available';
                            showAnswerNotAvailable = true;
                        } else {
                            answer = article.Procedure_Steps__c;
                            showAnswerNotAvailable = false;
                        }
                    }

                    return {
                        ...article,
                        Title: article.Title || '',
                        Answer__c: answer,
                        Knowledge_URL__c : article.Knowledge_URL__c||'Not Available',//Added By Himanshi Verma 28-01-25
                        showAnswerNotAvailable: showAnswerNotAvailable, // Updated property to control "Answer Not Available" message
                        Procedure_Audience__c: article.Procedure_Audience__c || '',
                        Procedure_Purpose__c: article.Procedure_Purpose__c || '',
                        Procedure_Steps__c: article.Procedure_Steps__c || '',
                        Procedure_Warnings__c: article.Procedure_Warnings__c || '',
                        Error__c: article.Error__c || '',
                        Error_Description__c: article.Error_Description__c || '',
                        showAnswer: false // Control answer visibility
                    };
                });
                this.error = undefined;
                console.log('data', this.data);
            })
            .catch(error => {
                console.log('error', error);
                this.error = error;
                this.data = [];
            });
    } else {
        // Clear data if there's no search text
        this.data = [];
    }
}




    changeHandler(event) {
        this.article = event.target.value;
        // Call fetchArticles() whenever the search text changes
        this.fetchArticles();
    }

    showAnswer(event) {
        const articleId = event.currentTarget.dataset.id;
        this.data = this.data.map(article => {
            if (article.Id === articleId) {
                return { ...article, showAnswer: !article.showAnswer };
            }
            return article;
        });
    }

    navigateToArticle(event) {
        event.preventDefault();
        const articleId = event.currentTarget.dataset.id;

        // Generate URL for the Knowledge Article detail page
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: articleId,
                objectApiName: 'Knowledge__kav',
                actionName: 'view'
            }
        }).then(url => {
            // Open the URL in a new tab
            window.open(url, '_blank');
        });
    }
}