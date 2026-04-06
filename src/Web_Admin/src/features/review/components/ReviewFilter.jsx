import React from 'react';
import { Select } from 'antd';
import { ShopOutlined } from '@ant-design/icons';
import FilterBar from '../../../components/FilterBar';

const { Option } = Select;

const ReviewFilter = ({ filters, stores = [], onFilterChange }) => {
  return (
    <FilterBar 
      onSearch={(value) => onFilterChange({ searchTerm: value, pageIndex: 1 })}
      searchPlaceholder="Tìm khách hàng, nội dung đánh giá..."
    >
      <Select
        placeholder={<span><ShopOutlined /> Chọn Cửa hàng</span>}
        allowClear
        showSearch
        optionFilterProp="children"
        style={{ width: 220 }}
        size="large"
        value={filters.storeId}
        onChange={(value) => onFilterChange({ storeId: value, pageIndex: 1 })}
      >
        {stores.map(store => (
          <Option key={store.id} value={store.id}>{store.name}</Option>
        ))}
      </Select>

      <Select
        placeholder="Lọc theo Số sao"
        allowClear
        style={{ width: 160 }}
        size="large"
        value={filters.rating}
        onChange={(value) => onFilterChange({ rating: value, pageIndex: 1 })}
      >
        <Option value={5}>⭐⭐⭐⭐⭐ (5)</Option>
        <Option value={4}>⭐⭐⭐⭐ (4)</Option>
        <Option value={3}>⭐⭐⭐ (3)</Option>
        <Option value={2}>⭐⭐ (2)</Option>
        <Option value={1}>⭐ (1)</Option>
      </Select>

      <Select
        placeholder="Trạng thái hiển thị"
        allowClear
        style={{ width: 160 }}
        size="large"
        value={filters.isHidden}
        onChange={(value) => onFilterChange({ isHidden: value, pageIndex: 1 })}
      >
        <Option value={false}>Đang hiển thị</Option>
        <Option value={true}>Đang bị ẩn</Option>
      </Select>
    </FilterBar>
  );
};

export default ReviewFilter;