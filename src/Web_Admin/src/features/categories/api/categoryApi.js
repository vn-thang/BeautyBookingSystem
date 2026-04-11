import axiosClient from '../../../api/axiosClient';

export const categoryApi = {
  getAllForAdmin: () => {
    return axiosClient.get('/api/AdminCategories/admin');
  },

  createCategory: (data) => {
    return axiosClient.post('/api/AdminCategories', data);
  },

  updateCategory: (id, data) => {
    return axiosClient.put(`/api/AdminCategories/${id}`, data);
  },

  deleteCategory: (id) => {
    return axiosClient.delete(`/api/AdminCategories/${id}`);
  }
};