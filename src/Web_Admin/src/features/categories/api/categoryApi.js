import axiosClient from '../../../api/axiosClient';

export const categoryApi = {
  getAllForAdmin: () => {
    return axiosClient.get('/api/GlobalCategories/admin');
  },

  createCategory: (data) => {
    return axiosClient.post('/api/GlobalCategories', data);
  },

  updateCategory: (id, data) => {
    return axiosClient.put(`/api/GlobalCategories/${id}`, data);
  },

  deleteCategory: (id) => {
    return axiosClient.delete(`/api/GlobalCategories/${id}`);
  }
};