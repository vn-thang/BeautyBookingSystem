import axiosClient from './axiosClient'; 

export const masterDataApi = {
  getStoresForDropdown: () => {
    return axiosClient.get('/api/admin/stores/dropdown'); 
  },
};