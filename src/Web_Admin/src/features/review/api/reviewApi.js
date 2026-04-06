import axiosClient from '../../../api/axiosClient'; 

export const reviewApi = {
  getReviews: (params) => {
    return axiosClient.get('/api/admin/reviews', { params });
  },

  toggleVisibility: (id, isHidden) => {
    return axiosClient.put(`/api/admin/reviews/${id}/visibility`, isHidden, {
      headers: { 'Content-Type': 'application/json' }
    });
  }
};