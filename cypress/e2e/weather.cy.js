describe('Weather App UI', () => {
  before(() => {
    cy.fixture('weather_data.json').then((data) => {
      globalThis.data = data;
  });
  } )
    beforeEach(() => {
      cy.visit('/'); 
    });
  
    it('Validates the page header', () => {
      cy.get('h1').should('have.text', data.pageHeader);
    })
    it('Loads default city (New York)', () => {
      cy.get('#weatherCard').should('be.visible');
      cy.get('#cityName').should('contain', data.defaultCity);
    });
  
    it('Fetches weather for valid city', () => {
      cy.get('#cityInput').clear().type(data.validCity);
      cy.get('#searchBtn').click();
      cy.get('#weatherCard').should('be.visible');
      cy.get('#cityName').should('contain', data.validCity);
    });
  
    it('Shows error for invalid city', () => {
      cy.get('#cityInput').clear().type(data.invalidCity);
      cy.get('#searchBtn').click();
      cy.get('#errorContainer').should('be.visible').and('contain', data.errorMessage);
    });
  
    it('Shows error for empty city input', () => {
      cy.get('#cityInput').clear();
      cy.get('#searchBtn').click();
      cy.get('#errorContainer').should('be.visible');
    });
  });
  