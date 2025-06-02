// Weather endpoint
app.get('/api/weather', async (req, res) => {
    const { city } = req.query;
    
    if (!city) {
        return res.status(400).json({ error: 'City parameter is required' });
    }

    try {
        const response = await axios.get(
            `https://api.openweathermap.org/data/2.5/weather?q=${city}&units=metric&appid=${OPENWEATHER_API_KEY}`
        );
        
        const weatherData = {
            city: response.data.name,
            country: response.data.sys.country,
            temperature: response.data.main.temp,
            humidity: response.data.main.humidity,
            pressure: response.data.main.pressure, // Add pressure
            wind: {
                speed: response.data.wind.speed,   // Add wind speed
                deg: response.data.wind.deg        // Add wind direction (optional)
            },
            conditions: response.data.weather[0].main,
            description: response.data.weather[0].description,
            icon: response.data.weather[0].icon
        };
        
        res.json(weatherData);
    } catch (error) {
        console.error('Error fetching weather data:', error.message);
        if (error.response && error.response.status === 404) {
            res.status(404).json({ error: 'City not found' });
        } else {
            res.status(500).json({ error: 'Failed to fetch weather data' });
        }
    }
});
