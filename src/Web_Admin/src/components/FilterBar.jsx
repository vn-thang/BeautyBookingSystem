import React from 'react';
import { Input, Space } from 'antd';
import { SearchOutlined } from '@ant-design/icons';

const FilterBar = ({ 
  onSearch, 
  searchPlaceholder = 'Tìm kiếm...', 
  children 
}) => {
  return (
    <div style={{ 
      display: 'flex', 
      justifyContent: 'space-between', 
      alignItems: 'center', 
      flexWrap: 'wrap', 
      gap: '16px', 
      marginBottom: '24px' 
    }}>
      <Space size="middle" wrap style={{ flex: 1 }}>
        {children}
      </Space>

      {onSearch && (
        <Input.Search 
          placeholder={searchPlaceholder} 
          allowClear
          enterButton={<SearchOutlined />}
          size="large"
          onSearch={onSearch} 
          style={{ width: '100%', maxWidth: '320px', minWidth: '250px' }}
        />
      )}
      
    </div>
  );
};

export default FilterBar;