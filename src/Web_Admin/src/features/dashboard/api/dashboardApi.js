import axiosClient from '../../../api/axiosClient';

export const dashboardApi = {
    getStatistics: (fromDate, toDate) => {
        return axiosClient.get('/api/admin/dashboard/statistics', {
            params: { fromDate, toDate }
        });
    }
};