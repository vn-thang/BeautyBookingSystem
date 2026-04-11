import axiosClient from '../../../api/axiosClient';

export const storeApi = {
  getAllStores: (params) => {
    return axiosClient.get('/api/admin/stores', { params });
  },
  getStoreById: (id) => axiosClient.get(`/api/admin/stores/${id}`),
  approveStore: (id) => {
    return axiosClient.put(`/api/admin/stores/${id}/approve`, {
      isApproved: true,
      remarks: "Đã duyệt bởi Admin" 
    });
  },

  updateStatus: (id, statusValue) => {
    return axiosClient.put(`/api/admin/stores/${id}/status`, {
      newStatus: statusValue 
    });
  },
  updateStoreFeeConfig: (id, feeData) => {
    return axiosClient.put(`/api/admin/stores/${id}/fees`, feeData);
  }
};