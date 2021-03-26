import axios from 'axios';

const backend = axios.create();
const apiBaseUrl = "https://capstone-api.wburklund.com";

let cachedAccessKey = null;
const getAccessKey = () => cachedAccessKey;
const resetAccessKey = () => cachedAccessKey = null;

backend.interceptors.request.use(config => {
    config.baseURL = apiBaseUrl
    config.headers['X-API-KEY'] = cachedAccessKey;
    return config;
}, null, { synchronous: true });

const login = async accessKey => {
    cachedAccessKey = accessKey
    return backend.get('/hello')
}

const predict = async file =>
    backend.post('/predict', file)
        .then(response => response.data)

const statistics = async () => 
    backend.get('/statistics')
        .then(response => response.data)

export {
    getAccessKey,
    resetAccessKey,
    login,
    predict,
    statistics
}
