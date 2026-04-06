import axiosClient from '../../../api/axiosClient';

export const systemConfigApi = {
    getAllConfigsGrouped: () => axiosClient.get('/api/admin/system-configs/grouped'),
    
    getConfigByKey: (key) => axiosClient.get(`/api/admin/system-configs/${key}`),
    
    updateConfig: (key, value) => {
        return axiosClient.put(`/api/admin/system-configs/${key}`, { 
            value: String(value) 
        });
    }
};