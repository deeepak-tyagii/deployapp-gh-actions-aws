document.addEventListener('DOMContentLoaded', () => {
    const cityInput = document.getElementById('cityInput');
    const searchBtn = document.getElementById('searchBtn');
    const weatherCard = document.getElementById('weatherCard');
    const errorContainer = document.getElementById('errorContainer');
    const loader = document.querySelector('.loader');
    
    // Elements to update
    const cityName = document.getElementById('cityName');
    const currentDate = document.getElementById('currentDate');
    const weatherIcon = document.getElementById('weatherIcon');
    const temperature = document.getElementById('temperature');
    const conditions = document.getElementById('conditions');
    const humidity = document.getElementById('humidity');
    const wind = document.getElementById('wind');
    const pressure = document.getElementById('pressure');

    const DEFAULT_CITY = 'New York'; // Define default city

    // Set current date
    updateCurrentDate();
    
    // Initial load: fetch weather for default city
    getWeather(DEFAULT_CITY);

    // Event listeners
    searchBtn.addEventListener('click', () => getWeather(cityInput.value.trim()));
    cityInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') getWeather(cityInput.value.trim());
    });
    
    async function getWeather(city) {
      // If city input is empty, use default city
      const cityToFetch = city === '' ? DEFAULT_CITY : city;
      
      // If the city is still empty after check (shouldn't happen with default), show error
      if (!cityToFetch) {
        showError('Please enter a city name');
        return;
      }
      
      // Show loader, hide card and error
      loader.classList.add('visible');
      weatherCard.classList.remove('visible');
      errorContainer.classList.add('hidden');
      
      try {
        // You'll need to replace 'YOUR_API_KEY' with your actual OpenWeatherMap API key
        // and set up a backend endpoint (e.g., /api/weather) to avoid exposing your API key
        // directly in client-side code.
        const response = await fetch(`/api/weather?city=${encodeURIComponent(cityToFetch)}`);
        const data = await response.json();
        
        if (response.ok) {
          displayWeather(data);
        } else {
          showError(data.error || 'Failed to fetch weather data');
        }
      } catch (error) {
        showError('An error occurred while fetching weather data');
        console.error('Error fetching weather data:', error);
      } finally {
        loader.classList.remove('visible');
      }
    }
    
    function displayWeather(data) {
      // Update all fields
      cityName.textContent = `${data.city}, ${data.country}`;
      temperature.textContent = Math.round(data.temperature);
      conditions.textContent = data.conditions;
      humidity.textContent = `${data.humidity}%`;
      
      // Add wind and pressure if available
      wind.textContent = data.wind ? `${data.wind.speed} km/h` : 'N/A';
      pressure.textContent = data.pressure ? `${data.pressure} hPa` : 'N/A';
      
      // Set weather icon
      weatherIcon.src = `https://openweathermap.org/img/wn/${data.icon}@4x.png`;
      weatherIcon.alt = data.description;
      
      // Show card with animation
      weatherCard.classList.add('visible');
    }
    
    function showError(message) {
      errorContainer.textContent = message;
      errorContainer.classList.remove('hidden');
    }
    
    function updateCurrentDate() {
      const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
      currentDate.textContent = new Date().toLocaleDateString('en-US', options);
    }
});