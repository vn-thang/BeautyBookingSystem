import React from 'react';
import { BookingStatus } from '@/constants'; 

const BookingStatusTag = ({ status }) => {
  const getStatusConfig = (val) => {
    switch (Number(val)) {
      case BookingStatus.Pending: return { color: '#f59e0b', bg: '#fef3c7', text: 'Chờ xác nhận' };
      case BookingStatus.Confirmed: return { color: '#3b82f6', bg: '#dbeafe', text: 'Đã xác nhận' };
      case BookingStatus.Completed: return { color: '#10b981', bg: '#d1fae5', text: 'Hoàn thành' };
      case BookingStatus.Cancelled: return { color: '#ef4444', bg: '#fee2e2', text: 'Đã hủy' };
      default: return { color: '#64748b', bg: '#f1f5f9', text: 'Không xác định' };
    }
  };

  const config = getStatusConfig(status);

  return (
    <span style={{ 
      backgroundColor: config.bg, 
      color: config.color, 
      padding: '4px 12px', 
      borderRadius: '8px', 
      fontWeight: 600, 
      fontSize: '13px' 
    }}>
      {config.text}
    </span>
  );
};

export default BookingStatusTag;