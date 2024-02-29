import { LightningElement } from 'lwc';
import PortfolioAssets from '@salesforce/resourceUrl/PortfolioAssets';

export default class PortfolioPersonalProjects extends LightningElement {

    BMICalculator = `${PortfolioAssets}/PortfolioAssets/Projects/BMICalculator.png`;
    AlarmClock = `${PortfolioAssets}/PortfolioAssets/Projects/AlarmClock.png`;
    CurrencyCalculator = `${PortfolioAssets}/PortfolioAssets/Projects/CurrencyCalculator.png`;
    WeatherApp = `${PortfolioAssets}/PortfolioAssets/Projects/WeatherApp.png`;
    SurveyApp = `${PortfolioAssets}/PortfolioAssets/Projects/Survey.png`;
    NoteTakingApp = `${PortfolioAssets}/PortfolioAssets/Projects/NoteTakingApp.png`;

    projects=[
        {
            "name":"BMI Calculator",
            "img":this.BMICalculator,
            "link":" https://mohitanwarportfolio-dev-ed.develop.my.site.com/"
        },
        {
            "name":"Alarm Clock",
            "img":this.AlarmClock,
            "link":" https://mohitanwarportfolio-dev-ed.develop.my.site.com/"
        },
        {
            "name":"Currency Calculator",
            "img":this.CurrencyCalculator,
            "link":" https://mohitanwarportfolio-dev-ed.develop.my.site.com/"
        },
        {
            "name":"Weather App",
            "img":this.WeatherApp,
            "link":" https://mohitanwarportfolio-dev-ed.develop.my.site.com/"
        },
        {
            "name":"Survey App",
            "img":this.SurveyApp,
            "link":" https://mohitanwarportfolio-dev-ed.develop.my.site.com/"
        },
        {
            "name":"Note Taking App",
            "img":this.NoteTakingApp,
            "link":" https://mohitanwarportfolio-dev-ed.develop.my.site.com/"
        }
    ]
}