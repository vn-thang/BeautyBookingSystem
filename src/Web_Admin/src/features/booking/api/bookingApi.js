import axiosClient from '../../../api/axiosClient';

export const bookingApi = {
  getBookings: (params) => {
    return axiosClient.get('/api/admin/bookings', { params });
  },

  getBookingDetail: (id) => {
    return axiosClient.get(`/api/admin/bookings/${id}`);
  },

  cancelBooking: (id, reason) => {
    return axiosClient.put(`/api/admin/bookings/${id}/cancel`, { reason }, {
      headers: { 'Content-Type': 'application/json' }
    });
  }
};