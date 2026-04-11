import React from 'react';
import { Tag, Button, Typography, Tooltip, Descriptions, Space, Image } from 'antd';
import { TransactionOutlined, ClockCircleOutlined } from '@ant-design/icons';
import dayjs from 'dayjs';
import CustomTable from '../../../components/CustomTable';

const { Text } = Typography;

const TRANSACTION_TYPES = {
    1: { label: 'Nạp tiền', color: 'green' },
    2: { label: 'Hoa hồng', color: 'volcano' },
    3: { label: 'Phí tháng', color: 'red' },
    4: { label: 'Hoàn tiền', color: 'cyan' },
    5: { label: 'Rút tiền', color: 'purple' },
};

const extractImageFromDescription = (text) => {
    if (!text) return { cleanText: 'Không có ghi chú', imageUrl: null };
    const regex = /\[Biên lai:\s*(https?:\/\/[^\]]+)\]/i;
    const match = text.match(regex);

    if (match) {
        return {
            cleanText: text.replace(match[0], '').trim(), 
            imageUrl: match[1] 
        };
    }

    return { cleanText: text, imageUrl: null };
};

const WalletTable = ({ transactions, loading, pagination, onChange, onOpenAdjustModal }) => {
    const columns = [
        {
            title: 'Cửa hàng',
            dataIndex: 'storeName',
            key: 'storeName',
            render: (text) => <Text strong style={{ color: '#1890ff' }}>{text}</Text>,
        },
        {
            title: 'Loại GD',
            dataIndex: 'type',
            key: 'type',
            render: (type) => {
                const config = TRANSACTION_TYPES[type] || { label: 'Khác', color: 'default' };
                return <Tag color={config.color} style={{ borderRadius: '4px' }}>{config.label.toUpperCase()}</Tag>;
            },
        },
        {
            title: 'Số tiền',
            dataIndex: 'amount',
            key: 'amount',
            render: (amount, record) => {
                const isPositive = [1, 4].includes(record.type);
                return (
                    <Text type={isPositive ? 'success' : 'danger'} strong style={{ fontSize: '15px' }}>
                        {isPositive ? '+' : ' '} {new Intl.NumberFormat('vi-VN').format(amount)} đ
                    </Text>
                );
            },
        },
        {
            title: 'Ngày GD',
            dataIndex: 'createdAt',
            key: 'createdAt',
            render: (date) => (
                <Space>
                    <ClockCircleOutlined style={{ color: '#bfbfbf' }} />
                    <Text type="secondary">{dayjs(date).format('DD/MM/YYYY')}</Text>
                </Space>
            ),
        },
        {
            title: 'Thao tác',
            key: 'action',
            align: 'center',
            width: 100,
            render: (_, record) => (
                <Tooltip title="Điều chỉnh ví (Nạp/Trừ)">
                    <Button 
                        type="primary" 
                        shape="circle" 
                        ghost 
                        icon={<TransactionOutlined />} 
                        onClick={() => onOpenAdjustModal(record.storeId, record.storeName)}
                    />
                </Tooltip>
            ),
        },
    ];

    const expandedRowRender = (record) => {
        const { cleanText, imageUrl } = extractImageFromDescription(record.description);

        return (
            <div style={{ backgroundColor: '#fafafa', padding: '16px 24px', borderRadius: '8px', border: '1px dashed #d9d9d9' }}>
                <Descriptions size="small" column={1} labelStyle={{ fontWeight: 600, width: '150px' }}>
                    <Descriptions.Item label="Thời gian chi tiết">
                        <Text>{dayjs(record.createdAt).format('DD/MM/YYYY HH:mm:ss')}</Text>
                    </Descriptions.Item>
                    
                    <Descriptions.Item label="Biến động số dư">
                        <Text type="secondary">{new Intl.NumberFormat('vi-VN').format(record.balanceBefore)} đ</Text>
                        <span style={{ margin: '0 8px', color: '#1890ff' }}>➞</span>
                        <Text strong>{new Intl.NumberFormat('vi-VN').format(record.balanceAfter)} đ</Text>
                    </Descriptions.Item>
                    
                    <Descriptions.Item label="Ghi chú hệ thống">
                        <div style={{ wordBreak: 'break-word', whiteSpace: 'pre-wrap', color: '#8c8c8c', fontStyle: 'italic' }}>
                            {cleanText}
                        </div>
                    </Descriptions.Item>
                    {imageUrl && (
                        <Descriptions.Item label="Chứng từ đính kèm">
                            <Image
                                width={120}
                                src={imageUrl}
                                alt="Biên lai giao dịch"
                                style={{ borderRadius: '6px', border: '1px solid #f0f0f0', objectFit: 'cover' }}
                                fallback="https://via.placeholder.com/120?text=Lỗi+tải+ảnh"
                            />
                        </Descriptions.Item>
                    )}
                </Descriptions>
            </div>
        );
    };

    return (
        <CustomTable
            columns={columns}
            dataSource={transactions}
            loading={loading}
            pagination={pagination}
            onChange={onChange}
            expandable={{ 
                expandedRowRender,
                expandRowByClick: true
            }}
             scroll={{ x: 800}}
        />
    );
};

export default WalletTable;