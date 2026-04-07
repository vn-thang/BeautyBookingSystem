import React from 'react';
import { Button } from 'antd';
import { EyeOutlined } from '@ant-design/icons';
import BookingStatusTag from './BookingStatusTag'; 
import PaymentStatusTag from './PaymentStatusTag'; 
import CustomTable from '../../../components/CustomTable';

const BookingList = ({ bookings, loading, pagination, onPageChange, onViewDetail }) => {

  const columns = [
    {
      title: 'Mã Đơn',
      dataIndex: 'id',
      key: 'id',
      render: (id) => <span style={{ fontWeight: 600, color: '#4318FF' }}>BK-{id}</span>
    },
    {
      title: 'Khách hàng',
      key: 'customer',
      render: (_, record) => (
        <div>
          <div style={{ fontWeight: 600, color: '#1E293B', fontSize: '15px' }}>{record.customerName}</div>
          <div style={{ fontSize: '13px', color: '#64748b' }}>{record.customerPhone}</div>
        </div>
      )
    },
    {
      title: 'Cửa hàng',
      dataIndex: 'storeName',
      key: 'storeName',
      render: (text) => <span style={{ color: '#475569', fontWeight: 500 }}>{text}</span>
    },
    {
      title: 'Tổng tiền',
      dataIndex: 'finalPrice',
      key: 'finalPrice',
      align: 'right',
      render: (price) => <span style={{ fontWeight: 700, color: '#1E293B', fontSize: '15px' }}>{price?.toLocaleString()} đ</span>
    },
    {
      title: 'Trạng thái', 
      dataIndex: 'status',
      key: 'status',
      align: 'center',
      render: (status) => <BookingStatusTag status={status} />
    },
    {
      title: 'Thanh toán', 
      dataIndex: 'paymentStatus',
      key: 'paymentStatus',
      align: 'center',
      render: (paymentStatus) => <PaymentStatusTag status={paymentStatus} />
    },
    {
      title: 'Thao tác',
      key: 'action',
      align: 'center',
      render: (_, record) => (
        <Button 
          type="text" 
          icon={<EyeOutlined style={{ color: '#3b82f6', fontSize: '18px' }} />} 
          onClick={() => onViewDetail(record.id)}
        />
      )
    }
  ];

  return (
    <CustomTable 
      columns={columns} 
      dataSource={bookings} 
      loading={loading}
      pagination={{
        current: pagination.pageIndex,
        pageSize: pagination.pageSize,
        total: pagination.totalCount,
        showSizeChanger: false, 
      }}
      onChange={(newPagination) => onPageChange(newPagination.current)}
    />
  );
};

export default BookingList;