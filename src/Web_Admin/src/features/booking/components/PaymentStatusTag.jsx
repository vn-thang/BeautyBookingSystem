import React from 'react';
const PaymentStatusConfig = {
  0: { color: '#64748b', bg: '#f1f5f9', text: 'Chưa thanh toán' },
  1: { color: '#10b981', bg: '#d1fae5', text: 'Đã thanh toán' },
  2: { color: '#ef4444', bg: '#fee2e2', text: 'Thất bại' },
  3: { color: '#3b82f6', bg: '#dbeafe', text: 'Đã hoàn tiền' },
};

const PaymentStatusTag = ({ status }) => {
  const numericStatus = Number(status);
  const config = PaymentStatusConfig[numericStatus] || PaymentStatusConfig[0];

  return (
    <span style={{ 
      backgroundColor: config.bg, 
      color: config.color, 
      padding: '4px 10px', 
      borderRadius: '6px', 
      fontWeight: 600, 
      fontSize: '12px' 
    }}>
      {config.text}
    </span>
  );
};

export default PaymentStatusTag;