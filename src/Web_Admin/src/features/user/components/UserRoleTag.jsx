import React from 'react';
import { UserRole } from '../../../constants';

const UserRoleTag = ({ role }) => {
  const getRoleConfig = (val) => {
    switch (Number(val)) {
      case UserRole.Admin: return { color: '#8b5cf6', bg: '#ede9fe', text: 'Admin' };
      case UserRole.StoreOwner: return { color: '#3b82f6', bg: '#dbeafe', text: 'Chủ Cửa Hàng' };
      default: return { color: '#14b8a6', bg: '#ccfbf1', text: 'Khách Hàng' };
    }
  };
  const config = getRoleConfig(role);
  return (
    <span style={{ backgroundColor: config.bg, color: config.color, padding: '4px 12px', borderRadius: '8px', fontWeight: 600, fontSize: '13px' }}>
      {config.text}
    </span>
  );
};
export default UserRoleTag;