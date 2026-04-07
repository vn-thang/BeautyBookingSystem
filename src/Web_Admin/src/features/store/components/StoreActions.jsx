import React from 'react';
import { Button } from 'antd';
import { EyeOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';

const StoreActions = ({ record }) => {
  const navigate = useNavigate();

  return (
    <Button 
      type="default" 
      icon={<EyeOutlined />} 
      size="small"
      onClick={() => navigate(`/stores/${record.id}`)}
    >
      Chi tiết
    </Button>
  );
};

export default StoreActions;