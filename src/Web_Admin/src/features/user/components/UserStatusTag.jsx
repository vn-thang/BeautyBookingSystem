import React from 'react';
import { UserStatus } from '../../../constants';

const UserStatusTag = ({ status }) => {
  const getStatusConfig = (val) => {
    switch (Number(val)) {
      case UserStatus.Active: return { color: '#10b981', bg: '#d1fae5', text: 'Hoạt động' };
      case UserStatus.Locked: return { color: '#ef4444', bg: '#fee2e2', text: 'Bị Khóa' };
      default: return { color: '#64748b', bg: '#f1f5f9', text: 'Chưa kích hoạt' };
    }
  };
  const config = getStatusConfig(status);
  return (
    <span style={{ backgroundColor: config.bg, color: config.color, padding: '4px 12px', borderRadius: '8px', fontWeight: 600, fontSize: '13px' }}>
      {config.text}
    </span>
  );
};
export default UserStatusTag;