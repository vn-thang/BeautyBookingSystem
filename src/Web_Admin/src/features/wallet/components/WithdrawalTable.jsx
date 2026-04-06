import React, { useState } from 'react';
import { Button, Space, Tag, Image, Typography, Tooltip } from 'antd';
import { CheckCircleOutlined, CloseCircleOutlined, BankOutlined } from '@ant-design/icons';
import ApproveWithdrawalModal from './ApproveWithdrawalModal'; 
import RejectWithdrawalModal from './RejectWithdrawalModal'; 
import CustomTable from '@/components/CustomTable';

const { Text } = Typography;

const WithdrawalTable = ({ dataSource, loading, onApprove, onReject, isHistoryTab }) => {
    const [approveModalVisible, setApproveModalVisible] = useState(false);
    const [rejectModalVisible, setRejectModalVisible] = useState(false);
    const [selectedRecord, setSelectedRecord] = useState(null);

    const isApproved = (status) => status === 'APPROVED' || status === 2;
    const isRejected = (status) => status === 'REJECTED' || status === 3;

    const handleOpenApproveModal = (record) => {
        setSelectedRecord(record);
        setApproveModalVisible(true);
    };

    const handleOpenRejectModal = (record) => {
        setSelectedRecord(record);
        setRejectModalVisible(true);
    };

    const columns = [
        {
            title: 'Mã GD',
            dataIndex: 'id',
            key: 'id',
            width: 90,
            render: (id) => <Text type="secondary">#{id}</Text>
        },
        {
            title: 'Cửa hàng',
            dataIndex: 'storeName',
            key: 'storeName',
            render: (text) => <Text strong style={{ color: '#2B3674', fontSize: '15px' }}>{text}</Text>
        },
        {
            title: 'Số tiền rút',
            dataIndex: 'amount',
            key: 'amount',
            render: (amount) => (
                <Text type="danger" strong style={{ fontSize: '16px' }}>
                    {Math.abs(amount || 0).toLocaleString('vi-VN')} đ 
                </Text>
            )
        },
        {
            title: 'Thông tin Ngân hàng',
            key: 'bankInfo',
            render: (_, record) => (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                    <Text strong style={{ color: '#1890ff' }}>
                        <BankOutlined style={{ marginRight: '6px' }} />
                        {record.bankName}
                    </Text>
                    <Space size="small">
                        <Tag color="geekblue" style={{ margin: 0, borderRadius: '4px' }}>
                            {record.bankAccountNumber}
                        </Tag>
                        <Text type="secondary" style={{ fontSize: '13px' }}>- {record.bankAccountName}</Text>
                    </Space>
                </div>
            )
        },
        ...(isHistoryTab ? [{
            title: 'Chi tiết xử lý',
            key: 'processDetail',
            render: (_, record) => (
                <div style={{ fontSize: '13px' }}>
                    {isApproved(record.status) ? (
                        record.receiptImageUrl ? (
                            <Image 
                                src={record.receiptImageUrl} 
                                width={60} 
                                style={{ borderRadius: '6px', border: '1px solid #f0f0f0' }} 
                            />
                        ) : <Text type="secondary" italic>Không có biên lai</Text>
                    ) : (
                        <Text type="secondary" italic>{record.adminNote || 'Không có lý do'}</Text>
                    )}
                </div>
            )
        }] : []),
        {
            title: isHistoryTab ? 'Trạng thái' : 'Thao tác',
            key: 'action',
            align: 'center',
            width: 180,
            render: (_, record) => {
                if (isHistoryTab) {
                    if (isApproved(record.status)) return <Tag color="success" style={{ padding: '4px 12px', borderRadius: '12px' }}>Đã duyệt</Tag>;
                    if (isRejected(record.status)) return <Tag color="error" style={{ padding: '4px 12px', borderRadius: '12px' }}>Đã từ chối</Tag>;
                    return <Tag color="default">{record.status}</Tag>; 
                }
                return (
                   <Space size="middle">
    <Tooltip title="Duyệt & Tải biên lai lên" color="#10b981">
        <Button 
            type="primary" 
            icon={<CheckCircleOutlined />} 
            onClick={() => handleOpenApproveModal(record)} 
            style={{ 
                backgroundColor: '#10b981', 
                borderColor: '#10b981', 
                borderRadius: '8px', 
                fontWeight: 600,
                padding: '0 16px',
                boxShadow: '0 4px 6px -1px rgba(16, 185, 129, 0.2)' 
            }}
        > 
            Duyệt 
        </Button>
    </Tooltip>

    <Tooltip title="Từ chối & Hoàn tiền vào ví" color="#ef4444">
        <Button 
            type="default" 
            danger 
            icon={<CloseCircleOutlined />}
            onClick={() => handleOpenRejectModal(record)}
            style={{ 
                borderRadius: '8px', 
                fontWeight: 600,
                padding: '0 16px'
            }}
        > 
            Từ chối 
        </Button>
    </Tooltip>
</Space>
                );
            },
        },
    ];

    return (
        <>
            <CustomTable 
                columns={columns} 
                dataSource={dataSource} 
                loading={loading}
                scroll={{ x: 900 }} 
            />

            {!isHistoryTab && (
                <>
                    <ApproveWithdrawalModal
                        visible={approveModalVisible}
                        record={selectedRecord}
                        onCancel={() => setApproveModalVisible(false)}
                        onConfirm={(id, url) => {
                            onApprove(id, url);
                            setApproveModalVisible(false);
                        }}
                    />
                    <RejectWithdrawalModal
                        visible={rejectModalVisible}
                        record={selectedRecord}
                        onCancel={() => setRejectModalVisible(false)}
                        onConfirm={(id, note) => {
                            onReject(id, note);
                            setRejectModalVisible(false);
                        }}
                    />
                </>
            )}
        </>
    );
};

export default WithdrawalTable;