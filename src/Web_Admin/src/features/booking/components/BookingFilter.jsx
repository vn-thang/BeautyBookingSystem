import React from 'react';
import { Select, Button, DatePicker, Space } from 'antd';
import { ReloadOutlined } from '@ant-design/icons';
import { BookingStatus } from '@/constants';
import FilterBar from '../../../components/FilterBar';

const { RangePicker } = DatePicker;

const BookingFilter = ({ filters, onChange, onRefresh }) => {
  const handleDateChange = (dates) => {
    if (dates) {
      onChange('fromDate', dates[0].format('YYYY-MM-DD'));
      onChange('toDate', dates[1].format('YYYY-MM-DD'));
    } else {
      onChange('fromDate', null);
      onChange('toDate', null);
    }
  };

  return (
    <FilterBar 
      onSearch={(value) => onChange('searchTerm', value)}
      searchPlaceholder="Tìm mã đơn, tên khách..."
    >
      <Space size="small" wrap>
        <Select
          placeholder="Lọc theo trạng thái hẹn"
          allowClear
          size="large"
          style={{ width: 180 }}
          value={filters.status !== '' ? filters.status : undefined}
          onChange={(value) => onChange('status', value ?? '')}
          options={[
            { value: BookingStatus.Pending, label: 'Chờ xác nhận' },
            { value: BookingStatus.Confirmed, label: 'Đã xác nhận' },
            { value: BookingStatus.Completed, label: 'Hoàn thành' },
            { value: BookingStatus.Cancelled, label: 'Đã hủy' },
          ]}
        />

        <Select
          placeholder="Lọc thanh toán"
          allowClear
          size="large"
          style={{ width: 160 }}
          value={filters.paymentStatus !== '' ? filters.paymentStatus : undefined}
          onChange={(value) => onChange('paymentStatus', value ?? '')}
          options={[
            { value: 0, label: 'Chưa thanh toán' },
            { value: 1, label: 'Đã thanh toán' },
            { value: 3, label: 'Đã hoàn tiền' },
          ]}
        />

        <RangePicker 
          size="large" 
          format="DD/MM/YYYY"
          placeholder={['Từ ngày', 'Đến ngày']}
          onChange={handleDateChange}
        />
      </Space>

      <Button size="large" icon={<ReloadOutlined />} onClick={onRefresh}>
        Tải lại
      </Button>
    </FilterBar>
  );
};

export default BookingFilter;