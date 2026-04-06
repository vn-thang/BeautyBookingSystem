import React from 'react';
import { Descriptions, Typography } from 'antd';

const { Text } = Typography;

const StoreOwnerInfo = ({ store }) => {
  return (
    <Descriptions 
      bordered 
      column={1} 
      labelStyle={{ width: '300px', backgroundColor: '#f8fafc', color: '#475569', fontWeight: 600 }} 
      contentStyle={{ backgroundColor: '#ffffff' }}
    >
      <Descriptions.Item label="Mã định danh (ID)">#{store.ownerId}</Descriptions.Item>
      <Descriptions.Item label="Họ và tên">
        <Text strong style={{ color: '#1E293B' }}>{store.ownerName || <Text type="secondary">N/A</Text>}</Text>
      </Descriptions.Item>
      <Descriptions.Item label="Email liên hệ">
        {store.ownerEmail ? <a href={`mailto:${store.ownerEmail}`}>{store.ownerEmail}</a> : <Text type="secondary">N/A</Text>}
      </Descriptions.Item>
    </Descriptions>
  );
};

export default StoreOwnerInfo;