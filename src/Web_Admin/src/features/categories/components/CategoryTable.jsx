import React from 'react';
import { Space, Button, Popconfirm, Tag, Avatar } from 'antd';
import { EditOutlined, DeleteOutlined, PictureOutlined } from '@ant-design/icons';
import CustomTable from '../../../components/CustomTable';

const CategoryTable = ({ dataSource, loading, onEdit, onDelete }) => {
  const columns = [
    {
      title: 'Icon',
      dataIndex: 'iconUrl',
      key: 'iconUrl',
      width: 80,
      align: 'center',
      render: (iconUrl) => (
        <Avatar 
          shape="square" 
          size="large"
          src={iconUrl} 
          icon={!iconUrl && <PictureOutlined />} 
          style={{ backgroundColor: '#f1f5f9', color: '#64748b', borderRadius: '8px' }}
        />
      ),
    },
    {
      title: 'Tên danh mục',
      dataIndex: 'name',
      key: 'name',
      render: (text) => <span style={{ fontWeight: 600, color: '#1E293B', fontSize: '15px' }}>{text}</span>,
    },
    {
      title: 'Thứ tự hiển thị',
      dataIndex: 'sortOrder',
      key: 'sortOrder',
      align: 'center',
      sorter: (a, b) => a.sortOrder - b.sortOrder,
      render: (order) => (
        <span style={{ backgroundColor: '#e0e7ff', color: '#4f46e5', padding: '2px 10px', borderRadius: '6px', fontWeight: 600 }}>
          {order}
        </span>
      )
    },
    {
      title: 'Trạng thái',
      dataIndex: 'isActive',
      key: 'isActive',
      align: 'center',
      render: (isActive) => (
        isActive 
          ? <span style={{ backgroundColor: '#d1fae5', color: '#10b981', padding: '4px 12px', borderRadius: '8px', fontWeight: 600, fontSize: '13px' }}>Đang hoạt động</span> 
          : <span style={{ backgroundColor: '#f1f5f9', color: '#64748b', padding: '4px 12px', borderRadius: '8px', fontWeight: 600, fontSize: '13px' }}>Đã ẩn</span>
      ),
    },
    {
      title: 'Hành động',
      key: 'action',
      align: 'center',
      render: (_, record) => (
        <Space size="middle">
          <Button 
            type="text" 
            icon={<EditOutlined style={{ color: '#3b82f6' }} />} 
            onClick={() => onEdit(record)}
          />
          <Popconfirm
            title="Bạn có chắc chắn muốn ẩn danh mục này?"
            description={
              <div style={{ maxWidth: '250px' }}>
                <p style={{ marginBottom: '4px' }}>Danh mục sẽ bị ẩn khỏi ứng dụng của khách hàng.</p>
                <p style={{ margin: 0, color: '#ef4444', fontWeight: 500 }}>
                  ⚠️ Lưu ý: Hệ thống sẽ từ chối ẩn nếu danh mục này vẫn còn dịch vụ hoạt động bên trong.
                </p>
              </div>
            }
            onConfirm={() => onDelete(record.id)}
            okText="Vẫn ẩn"
            cancelText="Hủy"
            okButtonProps={{ danger: true }}
          >
            <Button type="text" danger icon={<DeleteOutlined />} />
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <CustomTable 
      columns={columns} 
      dataSource={dataSource} 
      loading={loading}
      pagination={{ pageSize: 20 }} 
    />
  );
};

export default CategoryTable;