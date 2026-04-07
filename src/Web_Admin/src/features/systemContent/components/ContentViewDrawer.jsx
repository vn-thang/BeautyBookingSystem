import React, { useEffect, useState } from 'react';
import { Drawer, Spin, Typography, Divider, Space } from 'antd';
import { EyeOutlined } from '@ant-design/icons';
import { systemContentApi } from '../api/systemContentApi';
import 'react-quill-new/dist/quill.snow.css'; 

const ContentViewDrawer = ({ open, onClose, contentId }) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);

  const cleanContent = (html) => {
    if (!html) return '';
    return html.replace(/&nbsp;/g, ' ').replace(/\s+/g, ' '); 
  };

  useEffect(() => {
    if (open && contentId) {
      const fetchDetail = async () => {
        setLoading(true);
        try {
          const res = await systemContentApi.getByIdAdmin(contentId);
          setData(res.data || res);
        } finally {
          setLoading(false);
        }
      };
      fetchDetail();
    }
  }, [open, contentId]);

  return (
    <Drawer 
      title={
        <Space>
          <div style={{ backgroundColor: '#F0FDF4', padding: '6px 8px', borderRadius: '8px', color: '#10B981' }}>
            <EyeOutlined />
          </div>
          <span style={{ fontSize: '18px', fontWeight: 600, color: '#1E293B' }}>
            Chế độ Xem trước (Preview)
          </span>
        </Space>
      }
      width={800} 
      onClose={onClose} 
      open={open}
      destroyOnClose
    >
      <style>
      {`
        .custom-preview-content {
          text-align: justify;
          word-break: normal;
          overflow-wrap: break-word;
          white-space: normal;
          -webkit-hyphens: none;
          -ms-hyphens: none;
          hyphens: none;
          font-size: 16px;
          line-height: 1.8;
          color: #334155;
        }
        .custom-preview-content * {
          word-break: normal;
          white-space: normal;
        }
        .ql-editor {
          white-space: normal !important;
          word-break: normal !important;
          overflow-wrap: break-word !important;
        }
        .custom-preview-content ul, .custom-preview-content ol {
          padding-left: 24px;
        }
        .custom-preview-content h1, .custom-preview-content h2, 
        .custom-preview-content h3, .custom-preview-content h4 {
          text-align: left;
          margin-top: 1.5em;
          margin-bottom: 0.5em;
          color: #0f172a;
        }
      `}
      </style>

      <Spin spinning={loading}>
        {data && (
          <div style={{ padding: '16px' }}>
            <Typography.Title level={2} style={{ color: '#1E293B', marginBottom: '8px' }}>
              {data.title}
            </Typography.Title>

            <Typography.Text type="secondary" style={{ color: '#64748b' }}>
              Cập nhật lần cuối: {new Date(data.updatedAt).toLocaleString('vi-VN')}
            </Typography.Text>

            <Divider style={{ margin: '24px 0' }} />

            <div 
              className="ql-editor custom-preview-content"
              style={{ padding: 0 }}
              dangerouslySetInnerHTML={{ __html: cleanContent(data.content) }} 
            />
          </div>
        )}
      </Spin>
    </Drawer>
  );
};

export default ContentViewDrawer;