import React from 'react';
import { StoreStatus } from '../../../constants';

const StoreStatusTag = ({ status }) => {
  const getStatusConfig = (val) => {
    switch (Number(val)) {
      case StoreStatus.Incomplete: return { color: '#8b5cf6', bg: '#ede9fe', text: 'Chưa hoàn thiện' };
      case StoreStatus.Pending: return { color: '#f59e0b', bg: '#fef3c7', text: 'Chờ duyệt' };
      case StoreStatus.Approved: return { color: '#10b981', bg: '#d1fae5', text: 'Đã duyệt' };
      case StoreStatus.Locked: return { color: '#ef4444', bg: '#fee2e2', text: 'Đã khóa' };
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

export default StoreStatusTag;