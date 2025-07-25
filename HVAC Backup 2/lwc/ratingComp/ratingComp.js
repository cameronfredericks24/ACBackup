import { LightningElement, wire, track } from 'lwc';
import getAverageRating from '@salesforce/apex/CalculateAverageRating.getAverageRating';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import zeroStar from '@salesforce/resourceUrl/StarZero';
import halfStar from '@salesforce/resourceUrl/StarHalf';
import oneStar from '@salesforce/resourceUrl/StarOne';
import oneAndHalfStar from '@salesforce/resourceUrl/StarOneandHalf';
import twoStar from '@salesforce/resourceUrl/StarTwo';
import twoAndHalfStar from '@salesforce/resourceUrl/StarTwoandHalf';
import threeStar from '@salesforce/resourceUrl/StarThree';
import starThreeandHalf from '@salesforce/resourceUrl/StarThreeandHalf'; 
import fourStar from '@salesforce/resourceUrl/StarFour';
import fourAndHalfStar from '@salesforce/resourceUrl/StarFourandHalf';
import fiveStar from '@salesforce/resourceUrl/StarFive';
export default class RatingComp extends LightningElement {

    @track averageRating;
    @track error;
    @track userId = Id;
    @track currentUserName;
    // showzeroStar ;
    // showthreeAndHalfStar ; 
    showzeroStar;
    showhalfStar;
    showoneStar;
    showoneAndHalfStar;
    showtwoStar;
    showtwoAndHalfStar;
    showthreeStar;
    showthreeAndHalfStar; 
    showfourStar;
    showfourAndHalfStar;
    showfiveStar;

    // zeroStarImg = zeroStar;
    // starThreeandHalfImg = starThreeandHalf;
    zeroStarImg = zeroStar;
    halfStarImg = halfStar;
    oneStarImg = oneStar;
    oneAndHalfStarImg = oneAndHalfStar;
    twoStarImg = twoStar;
    twoAndHalfStarImg = twoAndHalfStar;
    threeStarImg = threeStar;
    starThreeandHalfImg = starThreeandHalf;
    fourStarImg = fourStar;
    fourAndHalfStarImg = fourAndHalfStar;
    fiveStarImg = fiveStar;
  

    @wire(getAverageRating)
    wiredAverageRating({ error, data }) {
        if (data) {
            this.averageRating = data;
            console.log('averageRating',this.averageRating );
            if (this.averageRating > 0 && this.averageRating < 1) {
                this.showhalfStar = true;
            } else if (this.averageRating === 1) {
                this.showoneStar = true;
            } else if (this.averageRating > 1 && this.averageRating < 2) {
                this.showoneAndHalfStar = true;
            } else if (this.averageRating === 2) {
                this.showtwoStar = true;
            } else if (this.averageRating > 2 && this.averageRating < 3) {
                this.showtwoAndHalfStar = true;
            } else if (this.averageRating === 3) {
                this.showthreeStar = true;
            } else if (this.averageRating > 3 && this.averageRating < 4) {
                this.showthreeAndHalfStar = true;
            } else if (this.averageRating === 4) {
                this.showfourStar = true;
            } else if (this.averageRating > 4 && this.averageRating < 5) {
                this.showfourAndHalfStar = true;
            } else if (this.averageRating === 5) {
                this.showfiveStar = true;
            } else {
                this.showzeroStar = true;
            }
        } else if (error) {
            console.error('Error fetching average rating', error);
        }
    }

   
    @wire(getRecord, { recordId: Id, fields: [UserNameFIELD]}) 
    currentUserInfo({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
        } else if (error) {
            console.error('Error ', error);
        }
    }
}