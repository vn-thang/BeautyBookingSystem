import React from 'react';
import { Descriptions, Typography } from 'antd';
import StoreStatusTag from '../StoreStatusTag';

const { Text } = Typography;

const StoreGeneralInfo = ({ store }) => {
  const currentBalance = store.walletBalance ?? store.WalletBalance ?? 0;
  const isDebt = store.walletBalance < 0;
  const rawDate = store.createdAt || store.CreatedAt;
  const isInvalidDate = !rawDate || rawDate.toString().startsWith('0001-01-01');
  const formattedDate = isInvalidDate ? 'Chưa cập nhật' : new Date(rawDate).toLocaleDateString('vi-VN');
  
  return (
    <Descriptions 
      bordered 
      column={1} 
      labelStyle={{ width: '300px', backgroundColor: '#f8fafc', color: '#475569', fontWeight: 600 }} 
      contentStyle={{ backgroundColor: '#ffffff' }}
    >
      <Descriptions.Item label="Trạng thái kiểm duyệt">
        <StoreStatusTag status={store.status} />
      </Descriptions.Item>
      <Descriptions.Item label="Tên cửa hàng">
        <Text strong style={{ fontSize: '15px', color: '#1E293B' }}>{store.name}</Text>
      </Descriptions.Item>
      <Descriptions.Item label="Số dư Ví">
        <Text strong style={{ fontSize: '15px', color: isDebt ? '#ef4444' : '#10b981' }}>
          {currentBalance.toLocaleString('vi-VN')} VNĐ
        </Text>
        {isDebt && (
          <span style={{ marginLeft: '12px', backgroundColor: '#fef2f2', color: '#ef4444', padding: '2px 8px', borderRadius: '4px', border: '1px solid #fca5a5', fontWeight: 600, fontSize: '12px' }}>
            ⚠️ ĐANG NỢ TIỀN
          </span>
        )}
      </Descriptions.Item>
      <Descriptions.Item label="Ngày tạo hệ thống">{formattedDate}</Descriptions.Item>
      <Descriptions.Item label="Số điện thoại liên hệ">{store.phone || <Text type="secondary">Chưa cập nhật</Text>}</Descriptions.Item>
      <Descriptions.Item label="Địa chỉ cụ thể">{store.address || <Text type="secondary">Chưa cập nhật</Text>}</Descriptions.Item>
      <Descriptions.Item label="Mô tả cửa hàng">{store.description || <Text type="secondary">Không có mô tả</Text>}</Descriptions.Item>
    </Descriptions>
  );
};

export default StoreGeneralInfo;