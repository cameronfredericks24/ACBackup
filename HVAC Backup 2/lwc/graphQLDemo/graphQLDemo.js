import { LightningElement, wire,track } from "lwc";
import { gql, graphql } from "lightning/uiGraphQLApi";
import { NavigationMixin } from 'lightning/navigation';


const columns = [
    { label: 'Id', fieldName: 'Id' },
    { label: 'Name', fieldName: 'Name', type: 'text' }
];



export default class GraphQLDemo extends LightningElement {
    @track results;
    errors;



    data = [];
    columns = columns;

  
    @wire(graphql, {
      query: gql`
        query AccountWithName {
          uiapi {
            query {
              Account(first: 20) {
                edges {
                  node {
                    Id
                    Name {
                      value
                    }
                    BillingCountry{
                        value
                    }
                    Email__c{
                        value
                    }
                  }
                }
              }
            }
          }
        }
      `,
    })
    graphqlQueryResult({ data, errors }) {
      if (data) {
        this.results = data.uiapi.query.Account.edges.map((edge) => edge.node);
        console.log('  this.results--',  this.results);
      }
      this.errors = errors;
    }


    redirectToURL() {
        // Define the URL you want to navigate to
        var url = 'https://bluestar-salesforce-data.s3.ap-south-1.amazonaws.com/testFolder/testfile';

        
        // Navigate to the external URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
        });
    }
}