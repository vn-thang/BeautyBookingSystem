import axiosClient from '../../../api/axiosClient';

export const walletApi = {
   getTransactions: (params) => {
    return axiosClient.get(`/api/admin/wallets/transactions`, {
        params
    });
    },
    adjustBalance: (storeId, data) => {
        return axiosClient.post(`/api/admin/wallets/stores/${storeId}/adjust`, data);
    },

    getPendingWithdrawals: (params) => {
        return axiosClient.get(`/api/admin/wallets/withdrawals/pending`, { 
            params 
        });
    },
    getProcessedWithdrawals: (params) => {
        return axiosClient.get(`/api/admin/wallets/withdrawals/history`, { params });
    },

    approveWithdrawal: (id, data) => {
        return axiosClient.put(`/api/admin/wallets/withdrawals/${id}/approve`, data);
    },
    rejectWithdrawal: (id, data) => {
        return axiosClient.put(`/api/admin/wallets/withdrawals/${id}/reject`, data);
    }
};