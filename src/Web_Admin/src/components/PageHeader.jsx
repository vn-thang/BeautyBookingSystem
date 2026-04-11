import React from 'react';
import { Button, Typography, Space } from 'antd';
import { ArrowLeftOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';

const { Title } = Typography;

const PageHeader = ({ title, showBack = false, extra }) => {
  const navigate = useNavigate();

  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
      <Space size="middle">
        {showBack && (
          <Button 
            type="text" 
            icon={<ArrowLeftOutlined />} 
            onClick={() => navigate(-1)} 
            style={{ color: '#64748b', backgroundColor: '#f1f5f9', borderRadius: '8px' }}
          />
        )}
        <Title level={4} style={{ margin: 0, color: '#1E293B', fontWeight: 700 }}>
          {title}
        </Title>
      </Space>
      {extra && <div>{extra}</div>}
    </div>
  );
};

export default PageHeader;