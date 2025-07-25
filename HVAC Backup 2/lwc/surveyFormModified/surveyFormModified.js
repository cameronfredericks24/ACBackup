import { LightningElement, api, track, wire } from 'lwc';
import getSurveyIdByInvitationNumber from '@salesforce/apex/SurveyFormController.getSurveyIdByInvitationNumber';
import getSurveyLanguages from '@salesforce/apex/SurveyFormController.getSurveyLanguages';
import getSurveyQuestion from '@salesforce/apex/SurveyFormController.getSurveyQuestion';
import saveSurveyResponses from '@salesforce/apex/SurveyFormController.saveSurveyResponses';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BlueStarLogo from '@salesforce/resourceUrl/BlueStarLogo';

export default class surveyForm extends LightningElement {

    @api surveyInvitationNum = '0002';
    quotedValue;

    @track surveyQuestions = [];
    myImageUrl = BlueStarLogo;
    welcomeMessageContent = '';
    hasWelcomeMessage = false;

    @track showThankYouScreen = false;
    @track surveyId;

    @track showErrorMessage = false;
    @track error;

    isLoading = false;

    languageOptions;

    selectedLanguage = 'English';

    connectedCallback() {
        this.fetchSurveyId();
     //   this.handleRatingClick = this.handleRatingClick.bind(this);
        this.template.addEventListener('change', this.handleCheckboxChange.bind(this));
    }

    async fetchSurveyId() {
        try {
            console.log('Invitation Number in fetchSurveyId:', this.surveyInvitationNum);
            const result = await getSurveyIdByInvitationNumber({ surveyInvitationNumber: this.surveyInvitationNum });
            console.log('Invitation Number in fetchSurveyId1:' + JSON.stringify(result));
            if (result !== null) {
                this.surveyId = result;
                this.fetchQuestions();
                this.loadSurveyQuestions();
            } else {
                console.error('No Survey record found for this Invitation Number');
                this.handleError();
            }
        } catch (error) {
            console.error('Error fetching Survey ID:', error);
            this.handleError();
        }
    }

    @wire(getSurveyLanguages, { surveyId: '$surveyId' })
    wiredLanguages({ error, data }) {
        console.log('Survey ID:', this.surveyId);
        if (data) {
            this.languageOptions = [];
            data.forEach(language => {
                const splitLanguages = language.Language__c.split(';');
                splitLanguages.forEach(lang => {
                    this.languageOptions.push({ label: lang, value: lang });
                });
            });
        } else if (error) {
            console.error('Error fetching survey languages:', error);
        }
    }

    handleError() {
        this.showErrorMessage = true;
        this.isLoading = false;
    }

    loadSurveyQuestions() {
        const selectedLanguage = 'English';
        if (this.surveyId) {
            getSurveyQuestion({ selectedLanguage, surveyId: this.surveyId })
                .then(result => {
                    console.log('Selected Language:', selectedLanguage);
                    console.log('Result from getSurveyQuestion:', result);
                    if (result && result.length > 0) {
                        console.log('Survey Questions:', result);
                        const processedQuestions = this.processQuestions(result);
                        this.surveyQuestions = processedQuestions;
                        this.checkForWelcomeMessage(processedQuestions);
                        this.generateRadioOptions();
                        this.generateDropdownOptions();
                        this.updateMaxRatingForRatingQuestions();
                        this.processButtonAnswer();
                        this.isLoading = false;
                    } else {
                        console.log('No survey questions found for the selected language.');
                    }
                })
                .catch(error => {
                    console.error('Error fetching survey questions:', error);
                });
        } else {
            console.error('Survey ID not available');
        }
    }

    handleLanguageChange(event) {
        this.selectedLanguage = event.target.value;
        this.fetchQuestions();
        if (this.surveyId) {
            getSurveyQuestion({ selectedLanguage: this.selectedLanguage, surveyId: this.surveyId })
                .then(result => {
                    if (result && result.length > 0) {
                        const processedQuestions = this.processQuestions(result);
                        this.surveyQuestions = processedQuestions;
                        this.checkForWelcomeMessage(processedQuestions);
                        this.generateRadioOptions();
                        this.generateDropdownOptions();
                        this.updateMaxRatingForRatingQuestions();
                        this.processButtonAnswer();
                    } else {
                        console.log('No survey questions found for the selected language.');
                    }
                })
                .catch(error => {
                    console.error('Error fetching survey questions:', error);
                });
        } else {
            console.error('Survey ID not available yet. Cannot fetch survey questions.');
        }
    }

    //order sorting
    processQuestions(questions) {
        return questions.map(question => ({
            ...question,
            Question__c: this.stripHtmlTags(question.Question__c),
            questionNumber: question.Order__c,
            answerType: question.Answer_Type__c,
        }))
            .sort((a, b) => a.Order__c - b.Order__c);
    }

    // Process questions and check for Welcome Message
    checkForWelcomeMessage(questions) {
        const welcomeMessage = questions.find(question => question.Type__c === 'Welcome Message');
        if (welcomeMessage) {
            this.hasWelcomeMessage = true;
            this.welcomeMessageContent = welcomeMessage.Question__c;
        }
    }

    stripHtmlTags(htmlString) {
        const tempElement = document.createElement('div');
        // eslint-disable-next-line @lwc/lwc/no-inner-html
        tempElement.innerHTML = htmlString;
        return tempElement.textContent || tempElement.innerText || '';
    }

    processButtonAnswer() {
        this.surveyQuestions.forEach(element => {
            if (element.Answer_Type__c === 'Button') {
                const answerValues = element.Answer_Values__c.split(',').map(value => value.trim());
                const buttons = answerValues.map((value, index) => ({
                    value,
                    textTop: this.getTextTop(value, answerValues),
                    isFirst: index === 0,
                    isLast: index === answerValues.length - 1
                }));
                element.buttons = buttons;
            } else if (element.Answer_Type__c === 'Dropdown' && element.Answer_Values__c) {
                this.generateDropdownOptions(element.Answer_Values__c);
            } else if (element.Answer_Type__c === 'Radio') {
                const answers = element.Answer_Values__c.split(',').map(answer => answer.trim());
                const maxRating = answers.length;
                element.options = answers.map(answer => ({ label: answer, value: answer, maxRating: maxRating }));
            } else if (element.Answer_Type__c === 'Rating' && element.Answer_Values__c) {
                const answerValues = element.Answer_Values__c.split(',').map(value => value.trim());
                const maxRating = answerValues.length; // Calculate the maxRating dynamically
                element.maxRating = maxRating; // Add maxRating property to the question object
                element.ratingArray = Array.from({ length: maxRating }, (_, index) => ({
                    value: index + 1,
                    style: '', // No initial styling needed here
                }));
            }
        })
    }

    //conditions
    get richLongTextQuestions() {
        return this.surveyQuestions.filter(question => question.Answer_Type__c === 'Long Text');
    }

    get radioQuestions() {
        return this.surveyQuestions.filter(question => question.Answer_Type__c === 'Radio');
    }

    get buttonQuestions() {
        if (this.surveyQuestions.length > 0) {
            return this.surveyQuestions.filter(question => question.Answer_Type__c === 'Button')
                .map(question => {
                    if (question.Answer_Values__c) {
                        const answerValues = question.Answer_Values__c.split(',').map(value => value.trim());
                        const buttons = answerValues.map((value, index) => ({
                            value,
                            textTop: this.getTextTop(value, answerValues),
                            isFirst: index === 0,
                            isLast: index === answerValues.length - 1
                        }));
                        return {
                            ...question,
                            buttons
                        };
                    }
                    return null;
                }).filter(buttonQuestion => buttonQuestion !== null);
        }
        return [];

    }

    get dropdownQuestions() {
        return this.surveyQuestions
            .filter(question => question.Answer_Type__c === 'Dropdown')
            .map(question => ({
                ...question,
                dropdownOptions: this.generateDropdownOptions(question.Answer_Values__c)
            }));
    }

    get ratingQuestions() {
        return this.surveyQuestions.filter(question => question.Answer_Type__c === 'Rating');
    }

    get sortedQuestions() {
        return [...this.surveyQuestions]
            .filter(question => question.Order__c !== 0)
            .sort((a, b) => a.Order__c - b.Order__c);
    }

    generateRadioOptions() {
        this.surveyQuestions.forEach(question => {
            if (question.Answer_Type__c === 'Radio' && question.Answer_Values__c) {
                const answers = question.Answer_Values__c.split(',').map(answer => answer.trim());
                const maxRating = answers.length;
                question.options = answers.map(answer => ({ label: answer, value: answer, maxRating: maxRating }));
            }
        });
    }

    generateDropdownOptions(answerValues) {
        if (answerValues) {
            const answers = answerValues.split(',').map(value => value.trim());
            return answers.map(answer => ({ label: answer, value: answer }));
        }
        return [];
    }

    getTextTop(buttonValue, answerValues) {
        if (buttonValue === answerValues[0]) {
            return 'POOR';
        } else if (buttonValue === answerValues[answerValues.length - 1]) {
            return 'BEST';
        }
        return '';
    }

    // Getter function to generate an array for rating iteration
    get ratingArray() {
        const selectedRating = 0; // Placeholder for selected rating (you can fetch this from your data)
        const ratingQuestion = this.surveyQuestions.find(question => question.Answer_Type__c === 'Rating');

        if (ratingQuestion && ratingQuestion.maxRating) {
            const maxRating = ratingQuestion.maxRating;
            return Array.from({ length: maxRating }, (_, index) => ({
                value: index + 1,
                style: index < selectedRating ? 'selected' : '', // Apply selected style based on the selected rating
            }));
        }
        // Return an empty array or handle this scenario based on your use case
        return [];
    }

    get checkboxGroupQuestions() {
        return this.surveyQuestions.filter(question => question.Answer_Type__c === 'Checkbox')
            .map(question => ({
                ...question,
                checkboxOptions: this.generateCheckboxOptions(question.Answer_Values__c)
            }));
    }

    generateCheckboxOptions(answerValues) {
        if (answerValues) {
            const answers = answerValues.split(',').map(value => value.trim());
            return answers.map(answer => ({ label: answer, value: answer }));
        }
        return [];
    }

    handleCheckboxChange(event) {
        try {
            const questionId = event.target.dataset.questionid;
            const selectedCheckboxes = this.template.querySelectorAll(`[data-questionid="${questionId}"]`);
            const selectedValues = [];

            selectedCheckboxes.forEach(checkbox => {
                if (checkbox.checked) {
                    selectedValues.push(checkbox.value);
                }
            });

            console.log('Question ID:', questionId);
            console.log('Selected Values:', selectedValues);

            if (questionId && selectedValues.length > 0) {
                this.updateSurveyQuestionResponse(questionId, selectedValues);
            }
        } catch (error) {
            console.error('Error in handleCheckboxChange:', error);
            this.showToast('Error', 'An error occurred while handling checkbox change: ' + error.message, 'error');
        }
    }



    // Update the selected rating
    updateSelectedRating(questionId, selectedRating) {
        const ratingQuestion = this.surveyQuestions.find(question => question.Id === questionId);

        if (ratingQuestion && ratingQuestion.maxRating) {
            ratingQuestion.ratingArray = ratingQuestion.ratingArray.map(star => ({
                ...star,
                style: star.value <= selectedRating ? 'selected' : '',
            }));
        }
    }

    updateMaxRatingForRatingQuestions() {
        const ratingQuestions = this.surveyQuestions.filter(question => question.Answer_Type__c === 'Rating');

        ratingQuestions.forEach(question => {
            if (question.Answer_Values__c) {
                const answerValues = question.Answer_Values__c.split(',').map(value => value.trim());
                const maxRating = answerValues.length; // Calculate the maxRating dynamically
                question.maxRating = maxRating; // Add maxRating property to the question object
                question.ratingArray = Array.from({ length: maxRating }, (_, index) => ({
                    value: index + 1,
                    style: '', // No initial styling needed here
                }));
            }
        });
    }

    //rating option logic
    // Handle click on a star to set the selected rating for a specific question
    handleRatingClick(event) {
        try {
            console.log('Star clicked!');
            const ratingValue = parseInt(event.target.dataset.value, 10);
            const questionId = event.currentTarget.closest('.rating-container').dataset.questionid;

            console.log('Rating Value:', ratingValue);
            console.log('Question ID:', questionId);

            const starElements = this.template.querySelectorAll(`[data-questionid="${questionId}"] span`);
            console.log('Star elements:', starElements);

            starElements.forEach(star => {
                const value = parseInt(star.dataset.value, 10);
                star.classList.toggle('selected', value <= ratingValue);
            });

            this.updateSelectedRating(questionId, ratingValue);
            this.updateSurveyQuestionResponse(questionId, ratingValue);
        } catch (error) {
            console.error('Error in handleRatingClick:', error);
            // Additional error handling logic if needed
        }
    }


    handleLongTextChange(event) {
        try {
            const questionId = event.target.dataset.id;
            const answer = event.target.value;
            if (questionId && answer !== null && answer !== undefined) {
                this.updateSurveyQuestionResponse(questionId, answer);
            } else {
                throw new Error('Invalid data provided for long text response saving');
            }
        } catch (error) {
            console.error('Error in handleLongTextChange:', error);
            this.showToast('Error', 'An error occurred while saving the long text response: ' + error.message, 'error');
        }
    }

    handleRadioChange(event) {
        const questionId = event.target.name;
        const selectedValue = event.detail.value;

        if (questionId && selectedValue) {
            this.updateSurveyQuestionResponse(questionId, selectedValue);
        }
    }

    handleDropdownChange(event) {
        const questionId = event.target.name;
        const selectedValue = event.detail.value;
        if (questionId && selectedValue) {
            this.updateSurveyQuestionResponse(questionId, selectedValue);
        }
    }

    handleBoxClick(event) {
        console.log('Box clicked!');
        const selectedValue = parseInt(event.target.getAttribute('data-value'), 10);
        const questionId = event.target.getAttribute('data-questionid');

        console.log('Selected Value:', selectedValue);
        console.log('Question ID:', questionId);

        if (!isNaN(selectedValue) && questionId) {
            const boxes = this.template.querySelectorAll(`[data-questionid='${questionId}']`);
            boxes.forEach(box => {
                box.classList.remove('selected-box');
            });
            event.target.classList.add('selected-box');
            this.updateSurveyQuestionResponse(questionId, selectedValue);
        }
    }

    updateSurveyQuestionResponse(questionId, answer) {
        this.surveyQuestions = this.surveyQuestions.map(question => {
            if (question.Id === questionId) {
                // For checkbox questions, update the response as an array of selected values
                if (question.Answer_Type__c === 'Checkbox') {
                    question.response = Array.isArray(answer) ? answer : [answer];
                } else {
                    question.response = answer;
                }
            }
            return question;
        });

    }

    handleSubmit() {
        try {
            const responsesToSave = this.surveyQuestions
                .filter(question => question.response !== undefined && question.response !== null)
                .map(question => ({
                    questionId: question.Id,
                    answer: this.getFormattedAnswer(question)
                }));

            if (responsesToSave.length > 0) {
                Promise.all(responsesToSave.map(response =>
                    saveSurveyResponses({
                        questionId: response.questionId,
                        answer: response.answer,
                        surveyInvitationNumber: this.surveyInvitationNum
                    })
                        .then(result => {
                            if (result && result.error) {
                                throw new Error('Error in saveSurveyResponses: ' + result.error);
                            }
                        })
                ))
                    .then(() => {
                        this.showToast('Success', 'Responses saved successfully', 'success');
                        this.showThankYouScreen = true;
                    })
                    .catch(error => {
                        console.error('Error in saveSurveyResponses:', error);
                        this.showToast('Error', 'Error saving responses: ' + error.message, 'error');
                    });
            } else {
                this.showToast('Error', 'No responses to save', 'error');
            }
        } catch (error) {
            console.error('Error in handleSubmit:', error);
            this.showToast('Error', 'An error occurred while processing the responses: ' + error.message, 'error');
        }
    }

    getFormattedAnswer(question) {
        if (question.Answer_Type__c === 'Checkbox') {
            // For checkbox type, join the selected values into a comma-separated string
            return question.response.join(', ');
        } else if (typeof question.response === 'string') {
            return question.response;
        }
        return JSON.stringify(question.response);

    }


    getErrorMessage(error) {
        if (Array.isArray(error.body)) {
            return error.body.map(err => err.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            return error.body.message;
        }
        return JSON.stringify(error);

    }

    questionList;
    fetchQuestions() {

    }

    // Method to show toast
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(evt);
    }
}