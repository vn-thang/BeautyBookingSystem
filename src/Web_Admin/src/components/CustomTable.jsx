import React from 'react';
import { Table } from 'antd';

const CustomTable = ({ 
  columns, 
  dataSource, 
  loading, 
  pagination, 
  onChange, 
  rowKey = 'id', 
  ...rest 
}) => {
  const defaultPagination = {
    position: ['bottomRight'],
    showSizeChanger: true,
    pageSizeOptions: ['10', '20', '50', '100'],
    showTotal: (total, range) => (
      <span style={{ color: '#64748b', fontWeight: 500 }}>
        Đang xem {range[0]}-{range[1]} / Tổng số {total} mục
      </span>
    ),
    ...pagination, 
  };

  return (
    <div className="custom-table-wrapper">
      <Table
        columns={columns} 
        dataSource={dataSource}
        rowKey={rowKey}
        loading={loading}
        pagination={pagination !== false ? defaultPagination : false}
        onChange={onChange}
        scroll={{ x: 'max-content' }} 
        size="middle" 
        {...rest} 
      />
    </div>
  );
};
export default CustomTable;