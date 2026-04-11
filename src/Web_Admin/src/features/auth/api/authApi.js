import axiosClient from '../../../api/axiosClient';

export const authApi = {
  login: (data) => axiosClient.post('/api/Auth/login', data),
  logout: () => axiosClient.post('/api/Auth/logout'),
  changePassword: (data) => axiosClient.put('/api/Auth/change-password', data),
};