import axiosClient from '../../../api/axiosClient'; 

export const userApi = {
  getAllUsers: (params) => {
    return axiosClient.get('api/admin/users', { params });
  },

  getUserById: (id) => {
    return axiosClient.get(`api/admin/users/${id}`);
  },

  updateUserStatus: (id, newStatus) => {
    return axiosClient.put(`api/admin/users/${id}/status`, { newStatus });
  }
};