import axios from 'axios';
const axiosClient = axios.create({
  baseURL: 'http://localhost:5294',
  headers: {
    'Content-Type': 'application/json',
  },
});

axiosClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

axiosClient.interceptors.response.use(
  (response) => {
    return response.data; 
  },
  async (error) => {
    const originalRequest = error.config;

    if (error.response && error.response.status === 401 && !originalRequest._retry) {
      
      originalRequest._retry = true; 
      
      const accessToken = localStorage.getItem('accessToken');
      const refreshToken = localStorage.getItem('refreshToken');

      if (accessToken && refreshToken) {
        try {
          const res = await axios.post('http://localhost:5294/api/Auth/refresh-token', {
            accessToken,
            refreshToken
          });

          const newTokens = res.data.data; 
          
          localStorage.setItem('accessToken', newTokens.accessToken);
          localStorage.setItem('refreshToken', newTokens.refreshToken);

          originalRequest.headers.Authorization = `Bearer ${newTokens.accessToken}`;
          
          return axiosClient(originalRequest);
          
        } catch (refreshError) {
          console.error('Phiên đăng nhập đã hết hạn hoàn toàn. Vui lòng đăng nhập lại!');
          localStorage.clear(); 
          window.location.href = '/login'; 
        }
      } else {
        localStorage.clear();
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);
export default axiosClient;