import React from 'react';
import { Select, DatePicker, Button, Space } from 'antd';
import { ReloadOutlined } from '@ant-design/icons';
import FilterBar from '../../../components/FilterBar';

const { RangePicker } = DatePicker;

const WalletFilterBar = ({ filters, setFilters, onSearch, onReset }) => {
    return (
        <FilterBar 
            onSearch={onSearch} 
            searchPlaceholder="Tìm theo tên cửa hàng..."
        >
            <Space size="small" wrap>
                <Select 
                    style={{ width: 180 }}
                    size="large"
                    placeholder="Loại giao dịch"
                    allowClear
                    value={filters.type}
                    onChange={val => setFilters({...filters, type: val})}
                    options={[
                        { value: 1, label: 'Nạp tiền' },
                        { value: 2, label: 'Thu hoa hồng' },
                        { value: 3, label: 'Thu phí tháng' },
                        { value: 4, label: 'Hoàn tiền' },
                        { value: 5, label: 'Rút tiền' },
                    ]}
                />

                <RangePicker 
                    size="large"
                    style={{ width: 260 }} 
                    value={filters.dateRange}
                    onChange={dates => setFilters({...filters, dateRange: dates})}
                    placeholder={['Từ ngày', 'Đến ngày']}
                    format="DD/MM/YYYY"
                />

                <Button size="large" icon={<ReloadOutlined />} onClick={onReset}>
                    Làm mới
                </Button>
            </Space>
        </FilterBar>
    );
};

export default WalletFilterBar;