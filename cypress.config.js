const { defineConfig } = require("cypress");

module.exports = defineConfig({
   e2e: {
        baseUrl: 'http://weatherapp-alb-1481460790.us-east-1.elb.amazonaws.com/',
        specPattern: 'cypress/e2e/**/*.{js,jsx,ts,tsx}'
    },
    reporter: 'junit',
});
