import React from 'react';
import { Rate, Switch, Typography, Tooltip, Avatar, Space } from 'antd';
import { UserOutlined } from '@ant-design/icons';
import dayjs from 'dayjs';
import CustomTable from '../../../components/CustomTable';

const { Text } = Typography;

const ReviewTable = ({ dataSource, loading, pagination, onTableChange, onToggleVisibility }) => {
  const columns = [
    {
      title: 'Khách hàng',
      dataIndex: 'customerName',
      key: 'customerName',
      render: (text, record) => (
        <Space>
          <Avatar icon={<UserOutlined />} src={record.customerAvatar} style={{ backgroundColor: '#f1f5f9', color: '#6366F1' }} />
          <Text strong style={{ color: '#1E293B' }}>{text || 'Khách vãng lai'}</Text>
        </Space>
      ),
    },
    {
      title: 'Cửa hàng',
      dataIndex: 'storeName',
      key: 'storeName',
      render: (text) => <span style={{ color: '#475569', fontWeight: 500 }}>{text}</span>
    },
    {
      title: 'Đánh giá',
      dataIndex: 'rating',
      key: 'rating',
      align: 'center',
      width: 150,
      render: (rating) => <Rate disabled defaultValue={rating} style={{ fontSize: 14, color: '#f59e0b' }} />,
    },
    {
      title: 'Nội dung',
      dataIndex: 'comment',
      key: 'comment',
      width: '25%',
      render: (comment) => (
        <Tooltip title={comment} placement="topLeft" color="#1E293B">
          <div style={{
            display: '-webkit-box',
            WebkitLineClamp: 2,
            WebkitBoxOrient: 'vertical',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            color: '#475569'
          }}>
            {comment || <Text type="secondary" italic>Không có bình luận</Text>}
          </div>
        </Tooltip>
      ),
    },
    {
      title: 'Ngày đánh giá',
      dataIndex: 'createdAt',
      key: 'createdAt',
      render: (date) => <span style={{ color: '#64748b' }}>{dayjs(date).format('DD/MM/YYYY HH:mm')}</span>,
    },
    {
      title: 'Trạng thái',
      key: 'status',
      align: 'center',
      render: (_, record) => (
        <span style={{ 
          backgroundColor: record.isHidden ? '#fee2e2' : '#d1fae5', 
          color: record.isHidden ? '#ef4444' : '#10b981', 
          padding: '4px 12px', 
          borderRadius: '8px', 
          fontWeight: 600, 
          fontSize: '13px' 
        }}>
          {record.isHidden ? 'Đã ẩn' : 'Hiển thị'}
        </span>
      ),
    },
    {
      title: 'Ẩn / Hiện',
      key: 'action',
      align: 'center',
      render: (_, record) => (
        <Tooltip title={record.isHidden ? "Click để hiển thị lại" : "Click để ẩn đánh giá này"}>
          <Switch
            checked={!record.isHidden}
            onChange={(checked) => onToggleVisibility(record.id, !checked)}
          />
        </Tooltip>
      ),
    },
  ];

  return (
    <CustomTable
      columns={columns}
      dataSource={dataSource}
      loading={loading}
      pagination={{
        current: pagination.pageIndex,
        pageSize: pagination.pageSize,
        total: pagination.totalCount,
      }}
      onChange={onTableChange} 
    
      expandable={{
        expandedRowRender: (record) => (
          <div style={{ 
            padding: '16px 24px', 
            background: '#F8FAFC', 
            borderRadius: '8px',
            border: '1px dashed #CBD5E1',
            marginLeft: '40px' 
          }}>
            <div style={{ marginBottom: '8px' }}>
              <Text strong style={{ color: '#4318FF' }}>💬 Phản hồi từ Chủ cửa hàng:</Text>
            </div>
            <Text style={{ color: '#475569', fontStyle: 'italic', fontSize: '14px', lineHeight: '1.6' }}>
              "{record.reply}"
            </Text>
          </div>
        ),
        rowExpandable: (record) => !!record.reply && record.reply.trim() !== '', 
      }}
    />
  );
};

export default ReviewTable;