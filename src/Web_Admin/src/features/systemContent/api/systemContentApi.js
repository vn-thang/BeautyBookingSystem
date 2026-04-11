import axiosClient from '../../../api/axiosClient'; 

export const systemContentApi = {
  getAllAdmin: () => {
    return axiosClient.get('api/admin/system-contents');
  },

  getByIdAdmin: (id) => {
    return axiosClient.get(`api/admin/system-contents/${id}`);
  },

  updateContent: (id, data) => {
    return axiosClient.put(`api/admin/system-contents/${id}`, data);
  },
  createContent: (data) => axiosClient.post('/api/admin/system-contents', data), 
  
  getByTypePublic: (type) => {
    return axiosClient.get(`/api/public/system-contents/type/${type}`); 
  }
};